# Preuves et clôture

Lire ce document avant un commit non-WIP, un passage en Review ou la clôture d’une PR. Les commandes et services propres au projet restent définis dans `workflow.md`.

## Règle de preuve

Toute preuve nomme le point fixe qu’elle couvre, idéalement le SHA du commit. Avant l’ouverture d’une PR, la preuve utile au passage de relais vit dans la demande ou l’issue qui porte la tâche. Dès qu’une PR existe, elle devient le dossier durable de la tâche et reprend les décisions antérieures qui doivent rester auditables.

Un rapport local, un fichier non publié ou une conversation avec un agent est un brouillon, sauf pour une tâche FAST sans issue ni PR, où la réponse à la demande est la trace durable. Il devient une preuve durable seulement lorsque son résultat est publié dans la PR sous forme de commentaire, review, mise à jour de la description ou lien vers un artefact conservé. Ne jamais publier de secret ni de donnée sensible.

## Commit non-WIP

Avant chaque commit présenté comme cohérent :

1. limiter le commit à un changement logique et identifier le contrôle le plus petit capable de le falsifier ;
2. exécuter ce contrôle sur le contenu qui sera commité ;
3. enregistrer le résultat et les contrôles plus profonds reportés dans le handoff ou la PR ;
4. conserver le dépôt installable et ne cacher aucune panne connue derrière un commit vert partiel.

Un changement du harness, de la CI, d’une version épinglée ou d’une intégration externe exige aussi le test négatif ou le preflight qui démontre le comportement modifié. La vérification complète reste obligatoire avant Review selon le niveau de risque.

## Preflight des services externes

Avant de figer une version, une dépendance ou une configuration liée à un service externe, vérifier :

- la capacité réellement disponible sur le compte et le plan visés, avec ses quotas ou coûts ;
- la compatibilité des versions et runtimes utilisés ;
- l’ordre de priorité entre la configuration du dépôt et les réglages distants ;
- la séparation entre preview, staging éventuel et production ;
- le contrôle non destructif qui prouvera le fonctionnement et le chemin de retour arrière.

Enregistrer dans l’issue ou la PR le service et la surface vérifiés, la date, le résultat, les inconnues et les décisions humaines nécessaires. Une inconnue qui peut modifier l’architecture, la dépendance ou le coût bloque le gel de ce choix. Le preflight n’autorise ni dépense, ni création de ressource, ni changement de production sans human gate correspondant.

## Matrice de clôture

Les couches ne se remplacent pas entre elles :

| Couche | Ce qu’elle prouve | Preuve attendue dans la PR |
|---|---|---|
| Locale | le changement fonctionne dans l’environnement de travail | commande, point fixe, résultat et limite éventuelle |
| CI | les contrôles reproductibles passent dans l’environnement automatisé | checks requis verts sur le même point fixe |
| Distante | les réglages GitHub, hébergeur ou service et le comportement déployé sont corrects | réglage observé, preview ou smoke test, sans secret |
| Review et human gate | un regard indépendant a couvert le diff et l’humain a pris les décisions réservées | rapport durable, traitement des findings et décision explicite |

Une couche non applicable porte `N/A` avec sa raison. `Non vérifié` reste une limite ou un blocage, jamais un synonyme de `N/A`.

## Rapport de review durable

Le rapport publié contient au minimum :

- l’identité du reviewer, son environnement, son modèle effectif, son rôle et la raison de son indépendance ;
- le point fixe ou la plage de diff examinée ;
- la spec, les conventions et les résultats de vérification reçus ;
- les axes couverts et les findings classés `BLOCKING`, `IMPORTANT` ou `SUGGESTION` ;
- la disposition de chaque finding et, après correction, le nouveau point fixe revu.

Un résumé de l’implémenteur ne remplace pas ce rapport. Le human gate est une décision humaine explicite dans la PR, distincte du rapport de review. Le merge lui-même n’en tient pas lieu : la décision est publiée avant le merge, par un commentaire ou une approbation qui nomme le commit candidat.

## Ordre de clôture

1. fixer le commit candidat et publier les preuves locales ;
2. obtenir les checks CI requis sur ce commit ;
3. vérifier les surfaces distantes pertinentes ;
4. publier puis traiter la review indépendante ;
5. obtenir le human gate requis ;
6. merger selon la convention du projet ;
7. exécuter les smoke tests post-merge, publier leur résultat puis fermer l’issue.
