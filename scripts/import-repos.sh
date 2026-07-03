#!/usr/bin/env bash
set -euo pipefail

# Run from the root of your existing monorepo.
#
# Usage:
#   ./import-repos.sh repos.txt
#
# repos.txt format:
#   <target-folder> <repo-url>
#
# Example:
#   app1 git@github.com:ORG/app1.git
#   app2 git@github.com:ORG/app2.git

REPOS_FILE="${1:-repos.txt}"
BRANCH="main"
WORKDIR="$(pwd)/.monorepo-import-work"

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "Run this script from inside your monorepo"
  exit 1
fi

MONOREPO_DIR="$(git rev-parse --show-toplevel)"
cd "$MONOREPO_DIR"

if ! command -v git-filter-repo >/dev/null 2>&1; then
  echo "Missing git-filter-repo"
  echo "Install with: brew install git-filter-repo"
  echo "Or: pipx install git-filter-repo"
  exit 1
fi

if [[ ! -f "$REPOS_FILE" ]]; then
  echo "Repos file not found: $REPOS_FILE"
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Monorepo has uncommitted changes. Commit or stash them first."
  exit 1
fi

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"

while read -r TARGET_FOLDER URL; do
  [[ -z "${TARGET_FOLDER:-}" ]] && continue
  [[ "$TARGET_FOLDER" =~ ^# ]] && continue

  echo
  echo "Importing $URL into ./$TARGET_FOLDER from branch $BRANCH..."

  IMPORT_DIR="$WORKDIR/import-$TARGET_FOLDER"

  git clone --branch "$BRANCH" "$URL" "$IMPORT_DIR"

  cd "$IMPORT_DIR"

  git filter-repo --to-subdirectory-filter "$TARGET_FOLDER"

  cd "$MONOREPO_DIR"

  git remote add "import-$TARGET_FOLDER" "$IMPORT_DIR"
  git fetch "import-$TARGET_FOLDER"

  git merge "import-$TARGET_FOLDER/$BRANCH" \
    --allow-unrelated-histories \
    --no-edit

  git remote remove "import-$TARGET_FOLDER"

done < "$REPOS_FILE"

rm -rf "$WORKDIR"

echo
echo "Done."
echo "Review with:"
echo "  git log --oneline --graph --all --decorate"
echo "  git log -- <folder>"
echo
echo "Push with:"
echo "  git push"
