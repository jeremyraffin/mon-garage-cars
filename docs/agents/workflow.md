# Workflow propre au projet

## 1. Projet

- Produit : Mon Garage Cars, catalogue visuel et sonore de miniatures *Cars* (voir `CONTEXT.md`).
- Utilisateurs principaux : un Enfant de quatre ans en Mode Enfant (lecture seule), des Parents qui entretiennent le Garage, un Propriétaire.
- Stack : client React, TypeScript et Vite (`src/`) ; Supabase pour Postgres, Auth, Storage et Edge Functions (`supabase/`) ; Playwright (`e2e/`) ; paquet npm unique, Node épinglé par `.nvmrc`. Décisions : ADR 0002, 0003 et 0005.
- Documentation métier : `CONTEXT.md` (langage), `docs/specs/0001-premier-garage-utilisable.md` (spec), `docs/adr/` (décisions), `docs/agents/bootstrap-plan.md` (plan de bootstrap).
- Propriétaire humain des décisions : Jérémy Raffin.
- Langue : branches, commits et titres de PR en anglais, avec les termes du domaine en français (`feat: add Fiche draft creation`) ; issues, specs, ADR et corps de PR en français.

### Environnements

| Environnement | Contenu | Données |
|---|---|---|
| local | `npm run dev` et pile Supabase locale (Docker Desktop) | identités et données factices |
| preview | Cloudflare Pages, un déploiement par PR | fixtures publiques, jamais le backend de production |
| staging | projet Supabase temporaire, réservé aux évolutions sensibles | factices |
| production | Cloudflare Pages depuis `main` après merge humain, et l'unique projet Supabase permanent | réelles, privées |

Déploiement Cloudflare Pages : branche de production `main`, build `npm ci && npm run build`, sortie `dist`. Cloudflare lit la version de Node dans `.nvmrc`, seule source de vérité : aucune variable `NODE_VERSION` n'est définie côté Cloudflare, ni en Production ni en Aperçu (les deux environnements ont leurs propres variables). Une variable `NODE_VERSION` oubliée dans l'un d'eux passe avant `.nvmrc` : pendant le bootstrap, celle de l'environnement Aperçu a ramené les builds de PR à Node 24.13.1. Les dépendances exigent Node 24.15 ou plus récent et `engine-strict` fait échouer l'installation sur une version plus ancienne.

## 2. Classification locale

### Exemples FAST

- correction de texte ou de documentation ;
- ajustement visuel local sans changement fonctionnel ;
- renommage mécanique limité ;
- ajustement d'une variable CSS ou d'un texte statique de la coquille, sans changement de comportement.

### Exemples STANDARD

- nouvelle interaction UI ;
- endpoint ou contrat d’API ;
- logique métier non critique ;
- bug non trivial ;
- refactor cohérent multi-fichiers ;
- nouveau composant du design system ou nouvelle route du client sans donnée privée.

### Exemples HIGH-RISK

- authentification, autorisation ou rôles ;
- données personnelles ou sensibles ;
- migration ou suppression de données ;
- paiement ou facturation ;
- changement d’infrastructure ou de déploiement critique ;
- intégration externe sensible ;
- politique RLS, Edge Function, Session d'appareil, invitation de Parent, Archive portable ou restauration ;
- workflow CI, secrets, variables d'environnement Cloudflare ou Supabase, branche de production.

## 3. Workflow par niveau

```text
FAST
micro-spec → implementation → verify:fast → petite PR/merge

STANDARD
grill si utile → spec → human gate si significative → implementation
→ verify → review indépendante → human review → squash merge

HIGH-RISK
grill + exploration → spec + analyse de risque + ADR si utile
→ human gate → petits tickets → implementation → verify complet
→ sécurité → review indépendante → human gate → merge
```

Une tâche peut monter de niveau en cours d’exécution. Elle ne redescend pas sans décision explicite.

## 4. GitHub

### Issues

- FAST : issue facultative si le contexte tient dans la demande et la PR.
- STANDARD simple : issue selon le besoin de traçabilité.
- STANDARD multi-session : issue de spec parente et tickets enfants.
- HIGH-RISK : issue de spec obligatoire ; tickets enfants si plusieurs tranches.

Conserver une hiérarchie simple :

```text
Issue de spec
├── tranche verticale 1
├── tranche verticale 2
└── tranche verticale 3
```

Chaque ticket doit être démontrable, tenir idéalement dans une session fraîche et posséder des critères d’acceptation falsifiables au point de départ.

### Labels minimaux

```text
type:spec     type:feature    type:bug
type:refactor type:security   type:chore

risk:fast     risk:standard   risk:high

blocked       needs-decision
```

Ajouter des labels `area:*` seulement quand ils deviennent utiles.

### Branches, commits et PR

```text
feat/123-short-description
fix/456-short-description
```

- Conventional Commits ; scope facultatif mais utile ;
- PR requise pour STANDARD et HIGH-RISK ;
- titre de PR compatible Conventional Commits ;
- description : What, Why, Verification, Risks, lien vers l’issue ;
- squash merge par défaut ;
- branche `main` protégée avec PR et checks requis.

## 5. Verification Harness

```bash
# Rapide : format et lint
npm run verify:fast

# Complet : verify:fast + types + tests unitaires + pgTAP + build + E2E
npm run verify

# Sécurité : verify + audit des dépendances + secrets + contrôles du build
npm run verify:security
```

Prérequis des commandes complètes : `npm ci`, `npm run e2e:install` (navigateurs Playwright) et Docker Desktop démarré. Une commande qui manque d'un prérequis échoue avec un message actionnable. Le contenu exact de chaque commande se lit dans les scripts de `package.json`.

Matrice du projet :

| Contrôle | FAST | STANDARD | HIGH-RISK | Commande/CI |
|---|---:|---:|---:|---|
| Format/lint ciblé | Oui | Oui | Oui | `npm run verify:fast` |
| Typecheck | Si pertinent | Oui | Oui | `npm run typecheck` |
| Tests unitaires | Ciblés | Oui | Oui | `npm run test` |
| Tests d’intégration | Non par défaut | Pertinents | Oui | `npm run db:test` (pgTAP) |
| Build | Si touché | Oui | Oui | `npm run build` |
| E2E | Non par défaut | Parcours touché | Parcours critiques | `npm run e2e` |
| SCA / dépendances | Non par défaut | CI | Oui | `npm audit --audit-level=high`, Dependabot |
| SAST / secrets | Non par défaut | Selon surface | Oui | `npm run secrets`, `npm run security:local`, CodeQL |

## 6. E2E

- Parcours critiques : aujourd'hui le chargement direct de `/` et `/garage` et le lien de la Vitrine vers le Garage ; chaque tranche produit ajoute ses parcours (publication d'une Fiche, lecture en Mode Enfant, Session d'appareil, matrice des rôles).
- Commande locale : `npm run e2e` sur Chromium et WebKit, après `npm run e2e:install`.
- Environnement de CI : GitHub Actions sur `ubuntu-24.04`, via `npm run verify:security`.
- Données de test : fixtures factices uniquement, jamais de photo ni de description du Garage réel.
- Artefacts en cas d’échec : traces, captures et vidéos Playwright conservées, téléversées par la CI pendant 7 jours.
- Règle anti-flaky : ne jamais relancer silencieusement jusqu’au vert ; diagnostiquer ou isoler explicitement.

## 7. Sécurité

Pour un dépôt public GitHub, activer au minimum selon la compatibilité du projet :

- Dependabot alerts et mises à jour ;
- secret scanning et push protection ;
- code scanning, idéalement CodeQL default setup si les langages sont pris en charge ;
- protection de la branche principale et checks obligatoires.

Contrôles supplémentaires du projet :

- SCA : `npm audit --audit-level=high` dans `verify:security` ; Dependabot hebdomadaire, délai de 7 jours avant de proposer une version récente, mises à jour majeures non groupées.
- SAST : CodeQL, workflow `.github/workflows/codeql.yml` (JavaScript/TypeScript et GitHub Actions) sur chaque PR, sur `main` et chaque lundi ; résultats dans le code scanning GitHub.
- secrets : secretlint (`npm run secrets`) avant commit et en CI ; secret scanning et push protection côté GitHub.
- contrôles du build : `npm run security:local` (aucun `.env` ni sauvegarde suivi par Git, aucune clé secrète dans `dist/`).
- conteneurs/IaC : N/A
- SBOM : N/A
- DAST : N/A
- procédure de divulgation : `SECURITY.md` (signalement privé GitHub).

Chaîne d'approvisionnement : versions npm exactes (`save-exact`), actions GitHub épinglées par SHA de commit, runner `ubuntu-24.04`. Toute nouvelle dépendance significative passe par un human gate.

Ne jamais placer de secret réel dans un prompt, une issue, un log, un fixture ou un dépôt.

## 8. Architecture

Avant une nouvelle abstraction :

1. rechercher le pattern existant ;
2. identifier les zones impactées et les tests voisins ;
3. comparer au moins le maintien de l’existant avec l’alternative ;
4. rendre explicites les compromis et la migration ;
5. obtenir la validation humaine si le choix est durable ou difficile à inverser.

Contraintes locales :

- limites de modules : un paquet unique ; `src/` pour le client, `supabase/` pour le backend versionné, `e2e/` pour les parcours transversaux, `public/` pour les seuls éléments publics (ADR 0005). Les lectures passent par Supabase sous RLS, les mutations par les Edge Functions (ADR 0003).
- dépendances : celles de `package.json` ; variables CSS et CSS Modules comme seule couche de style. Une bibliothèque UI, Storybook, un framework CSS, un second paquet ou un outil d'analytics demandent une nouvelle décision.
- règles de compatibilité : Safari iPhone et iPad en priorité, Chrome Android, puis navigateurs de bureau récents ; tests automatisés sur Chromium et WebKit ; Node 24.15 ou plus récent.
- exigences de performance : aucune cible chiffrée dans la spec 0001 ; chaque spec de tranche fixe les siennes.
- observabilité : aucun analytics comportemental ; aucune photo, description, jeton ni secret dans les journaux ou chez un outil tiers ; diagnostic technique détaillé réservé à l'Espace Parent.

## 9. ADR

Créer un ADR pour une décision durable, transversale, coûteuse à inverser ou structurante. Ne pas créer d’ADR pour une simple décision d’implémentation locale.

Emplacement : `docs/adr/NNNN-titre.md`

```md
# NNNN — Titre

Statut : Proposed | Accepted | Superseded
Date : YYYY-MM-DD

## Contexte
## Décision
## Alternatives considérées
## Conséquences
## Plan de validation ou de retour arrière
```

## 10. Definition of Done

- critères d’acceptation satisfaits ;
- scope respecté ;
- tests et documentation adaptés ;
- commande de vérification appropriée verte ;
- aucun secret ni nouvelle alerte de sécurité connue ;
- review indépendante traitée pour STANDARD/HIGH-RISK ;
- human gate franchi lorsqu’il est requis ;
- issue/PR/ADR liés ;
- risques résiduels explicités.
