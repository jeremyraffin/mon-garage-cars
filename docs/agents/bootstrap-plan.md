# Plan de bootstrap

Statut : Accepted
Date : 2026-10-02
Validation humaine : 2026-10-02
Propriétaire des décisions : Jérémy Raffin

## But

Transformer le dépôt documentaire vide en base reproductible prête à recevoir les tranches de `docs/specs/0001-premier-garage-utilisable.md`. Le bootstrap installe le socle, les contrôles et le pilotage ; il ne développe ni authentification, ni modèle métier, ni galerie, ni import du prototype.

Le setup initial du workflow Matt Pocock est déjà terminé. Le bootstrap adapte les fichiers présents et ne relance jamais ce setup.

## Gate de départ

Commencer uniquement après que le Propriétaire a remplacé le statut de ce plan par `Accepted` ou a donné une validation explicite équivalente. Jusqu’à cette validation :

- conserver le bloc `BOOTSTRAP_REQUIRED` dans `AGENTS.md` ;
- conserver tous les placeholders `<À_ADAPTER>` ;
- ne créer aucun commit, issue, projet distant, déploiement ou dépendance ;
- ne modifier aucune configuration GitHub, Cloudflare, Google ou Supabase.

## Préconditions humaines

Avant les étapes qui en dépendent, le Propriétaire :

- installe et démarre Docker Desktop après acceptation de sa licence ;
- confirme qu’un emplacement Supabase gratuit est disponible pour la production ;
- fournit ou crée les comptes Cloudflare, Supabase et Google nécessaires sans transmettre leurs secrets dans un prompt ou le dépôt ;
- choisit les six à dix Fiches et photos autorisées pour la Vitrine ;
- autorise explicitement le commit initial décrit ci-dessous.

## Étapes

### 1. Établir le point de départ Git

Le dépôt n’a aucun commit et tous les fichiers actuels sont non suivis. Effectuer un unique commit initial documentaire sur `main`, contenant seulement le workflow Matt Pocock existant, `CONTEXT.md`, les ADR et les specs approuvées.

Ne pas inclure le prototype HTML, les photos, des sauvegardes, des variables d’environnement ou des secrets.

**Terminé lorsque** le commit initial est relu par le Propriétaire, poussé sur `main`, et que son contenu correspond exactement aux fichiers documentaires approuvés.

### 2. Créer le pilotage GitHub

- créer les labels définis par `docs/agents/workflow.md` et `docs/agents/triage-labels.md` ;
- créer une issue de spec parente HIGH-RISK pour le premier Garage utilisable ;
- créer une sous-issue de bootstrap technique pour exécuter le présent plan ;
- créer une sous-issue pour chacune des six tranches produit de la spec, en conservant leur ordre ;
- représenter les dépendances avec les sous-issues et dépendances GitHub natives ;
- laisser chaque sous-issue hors de `ready-for-agent` jusqu’à l’approbation de sa spec propre.

**Terminé lorsque** l’issue parente expose le résultat attendu, le hors-périmètre, les critères de succès, les liens vers les ADR et toutes les sous-issues ordonnées.

### 3. Ouvrir la branche de bootstrap

Créer une branche dédiée depuis le commit initial. Toutes les étapes suivantes passent par une PR ; aucun autre changement n’est poussé directement sur `main`.

**Terminé lorsque** la branche est liée à l’issue de bootstrap et que la PR peut accueillir les contrôles au fur et à mesure.

### 4. Créer le squelette applicatif

- épingler Node 24 LTS et utiliser npm ;
- créer un client React, TypeScript et Vite à paquet unique ;
- réserver `src/` au client, `supabase/` au backend versionné, `e2e/` aux parcours Playwright et `public/` aux seuls éléments publics ;
- installer seulement les dépendances approuvées nécessaires au routage, au build, au formatage, au lint et aux tests ;
- utiliser des variables CSS et des CSS Modules ;
- créer un design system interne minimal, sans Storybook ni bibliothèque générale de composants ;
- produire une coquille neutre permettant de vérifier `/` et `/garage`, sans donnée privée ni comportement produit.

**Terminé lorsque** une installation propre et un build reproduisent la coquille sur les deux routes, sans avertissement bloquant ni secret dans les artefacts.

### 5. Initialiser Supabase localement

- ajouter la CLI Supabase comme dépendance de développement épinglée ;
- initialiser `supabase/` sans lier le dépôt à la production ;
- préparer les emplacements versionnés pour schéma déclaratif ou migrations, seeds factices, tests pgTAP et Edge Functions ;
- utiliser uniquement des identités et données factices ;
- documenter le démarrage local avec Docker Desktop et l’arrêt propre de la pile.

**Terminé lorsque** un clone propre peut démarrer la pile locale, exécuter un test de base vide et l’arrêter sans contacter la production.

### 6. Installer le Verification Harness

Configurer des commandes npm stables pour :

- `verify:fast` : format en vérification et lint rapides ;
- `verify` : format, lint, TypeScript, tests unitaires, tests de base, build et E2E pertinents ;
- `verify:security` : vérification complète, audit des dépendances, détection de secrets et contrôles de sécurité locaux disponibles.

Ajouter :

- Vitest et Testing Library ;
- Playwright sur Chromium et WebKit ;
- pgTAP via la CLI Supabase ;
- des tests TypeScript pour les Edge Functions ;
- un hook natif versionné dans `.githooks/pre-commit`, activé explicitement, qui appelle uniquement `verify:fast` ;
- des artefacts Playwright en cas d’échec.

Les commandes complètes possèdent leurs prérequis ou échouent avec une explication actionnable. Aucun hook ne remplace la CI.

**Terminé lorsque** les trois commandes existent, sont documentées, échouent sur un défaut volontaire adapté à leur niveau et repassent au vert après son retrait.

### 7. Configurer la CI et la sécurité GitHub

- exécuter la vérification appropriée sur chaque PR ;
- activer Dependabot avec un passage hebdomadaire et séparer les mises à jour majeures ;
- activer secret scanning, push protection et CodeQL ;
- activer la protection de `main`, les PR obligatoires et les checks requis ;
- conserver le déploiement de production derrière le merge humain d’une PR approuvée ;
- n’utiliser que les runners standards gratuits du dépôt public ;
- exclure des logs et artefacts les secrets, jetons, photos et descriptions privées.

**Terminé lorsque** une PR de test exécute les checks, bloque un échec et produit les rapports attendus sans donnée privée.

### 8. Préparer les environnements et le déploiement statique

- définir local, preview et production ;
- connecter Cloudflare Pages au dépôt public pour les previews et la production statique ;
- utiliser des fixtures publiques pour les previews ;
- ne connecter aucun preview au backend de production ;
- conserver un seul projet Supabase distant permanent ;
- documenter le staging temporaire comme option réservée aux évolutions sensibles ;
- utiliser initialement le domaine gratuit de Cloudflare Pages.

**Terminé lorsque** la coquille statique se déploie, que `/` et `/garage` se rechargent correctement et qu’aucun secret ou endpoint privé n’est présent dans la Vitrine.

### 9. Ajouter les documents publics minimaux

- `README.md` : but, statut, démarrage local et liens vers la spec et les ADR ;
- `SECURITY.md` : signalement privé et attentes de traitement ;
- `LICENSE` : MIT pour le code ;
- `NOTICE` : exclusion des photos et données de démonstration de la licence logicielle, propriété des marques et personnages, absence d’affiliation ;
- `.env.example` : noms de variables et valeurs factices uniquement.

La documentation du workflow reste publiquement réutilisable. Les photos, données privées, sauvegardes et secrets ne sont jamais ajoutés au dépôt.

**Terminé lorsque** un nouveau contributeur peut identifier le scope, démarrer le squelette et savoir quelles données sont publiables sans connaissance orale.

### 10. Adapter les règles des agents en dernier

Une fois le harness réellement exécutable :

- remplacer chaque `<À_ADAPTER>` de `docs/agents/workflow.md` par les décisions et commandes vérifiées ;
- reporter les trois commandes de vérification exactes dans `AGENTS.md` ;
- ajouter des pointeurs concis vers la spec, `CONTEXT.md`, les ADR et ce plan ;
- conserver la matrice de modèles v0.1 inchangée ;
- supprimer le bloc `BOOTSTRAP_REQUIRED` seulement lorsque tous les critères du bootstrap sont satisfaits.

**Terminé lorsque** aucun placeholder ne subsiste, chaque pointeur mène à une source de vérité unique et un agent peut classifier puis vérifier une tâche sans supposition.

### 11. Review et human gate

Classer le bootstrap HIGH-RISK en raison de la CI, des secrets, des environnements et de la future surface d’authentification. Fournir au reviewer indépendant la spec, les ADR, le diff complet et les sorties des trois commandes.

Traiter tous les findings `BLOCKING` et `IMPORTANT`, puis demander la validation humaine avant le squash merge.

**Terminé lorsque** la review indépendante ne contient plus de finding bloquant ou important non résolu, les checks requis sont verts et le Propriétaire autorise le merge.

## Vérification finale du bootstrap

La PR de bootstrap ne peut être déclarée terminée que si :

- l’installation depuis le lockfile réussit ;
- `verify:fast`, `verify` et `verify:security` réussissent ;
- le build statique et le routage direct des deux espaces réussissent ;
- la pile Supabase locale démarre et ses tests passent ;
- les workflows GitHub passent sur une PR réelle ;
- la protection de branche et les fonctions de sécurité sont actives ;
- aucun `<À_ADAPTER>` ni `BOOTSTRAP_REQUIRED` ne subsiste ;
- aucun secret, photo privée, sauvegarde ou contenu du prototype n’est suivi par Git ;
- les risques résiduels et prérequis humains sont rapportés.

## État après bootstrap

Le dépôt est prêt pour la première sous-issue produit. Le bootstrap ne donne pas une autorisation globale d’implémenter les six tranches : chaque sous-issue STANDARD ou HIGH-RISK conserve sa spec, son human gate, ses tests et sa review propres.
