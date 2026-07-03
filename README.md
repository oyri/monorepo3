# monorepo3
Teste monorepo merge.

### Framgongsmåte for å importere repos med historikk inn til monorepo

#### Forutsetnader
Installert git-filter-repo:
```brew install git-filter-repo```

Laga nytt, tomt monorepo med minst 1 initiell commit og clona ned dette lokalt. 

Ingen opne PR (dependabot kan vera opne, vil bli oppretta på ny seinare att) eller kode på andre branches på repos som skal flyttas inn i nytt monorepo.
Berre main-branch vil bli flytta over.

#### Køyring
Gå til mappa scripts og flytt alle filene på utsida av monorepoet og køyr slik:
```
./../import-repos.sh ../repos.txt
```
Denne jobben er utført på dette repoet, så sjå på historikken på denne som døme.
