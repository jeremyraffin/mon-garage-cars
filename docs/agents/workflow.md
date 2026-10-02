# Workflow propre au projet

> Remplacer tous les marqueurs `<À_ADAPTER>`, puis supprimer cette note.

## 1. Projet

- Produit : `<À_ADAPTER>`
- Utilisateurs principaux : `<À_ADAPTER>`
- Stack : `<À_ADAPTER>`
- Environnements : `<local / preview / staging / production>`
- Documentation métier : `<chemins ou liens>`
- Propriétaire humain des décisions : `<À_ADAPTER>`

## 2. Classification locale

### Exemples FAST

- correction de texte ou de documentation ;
- ajustement visuel local sans changement fonctionnel ;
- renommage mécanique limité ;
- `<À_ADAPTER>`.

### Exemples STANDARD

- nouvelle interaction UI ;
- endpoint ou contrat d’API ;
- logique métier non critique ;
- bug non trivial ;
- refactor cohérent multi-fichiers ;
- `<À_ADAPTER>`.

### Exemples HIGH-RISK

- authentification, autorisation ou rôles ;
- données personnelles ou sensibles ;
- migration ou suppression de données ;
- paiement ou facturation ;
- changement d’infrastructure ou de déploiement critique ;
- intégration externe sensible ;
- `<À_ADAPTER>`.

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
feat/123-courte-description
fix/456-courte-description
```

- Conventional Commits ; scope facultatif mais utile ;
- PR requise pour STANDARD et HIGH-RISK ;
- titre de PR compatible Conventional Commits ;
- description : What, Why, Verification, Risks, lien vers l’issue ;
- squash merge par défaut ;
- branche `main` protégée avec PR et checks requis.

## 5. Verification Harness

```bash
# Rapide : contrôles ciblés, idéalement moins de quelques minutes
<À_ADAPTER: verify:fast>

# Complet : format/lint + types + tests + build + E2E pertinent
<À_ADAPTER: verify>

# Sécurité : dépendances + secrets + SAST et contrôles pertinents
<À_ADAPTER: verify:security>
```

Matrice du projet :

| Contrôle | FAST | STANDARD | HIGH-RISK | Commande/CI |
|---|---:|---:|---:|---|
| Format/lint ciblé | Oui | Oui | Oui | `<À_ADAPTER>` |
| Typecheck | Si pertinent | Oui | Oui | `<À_ADAPTER>` |
| Tests unitaires | Ciblés | Oui | Oui | `<À_ADAPTER>` |
| Tests d’intégration | Non par défaut | Pertinents | Oui | `<À_ADAPTER>` |
| Build | Si touché | Oui | Oui | `<À_ADAPTER>` |
| E2E | Non par défaut | Parcours touché | Parcours critiques | `<À_ADAPTER>` |
| SCA / dépendances | Non par défaut | CI | Oui | `<À_ADAPTER>` |
| SAST / secrets | Non par défaut | Selon surface | Oui | `<À_ADAPTER>` |

## 6. E2E

- Parcours critiques : `<À_ADAPTER>`
- Commande locale : `<À_ADAPTER>`
- Environnement de CI : `<À_ADAPTER>`
- Données de test : `<À_ADAPTER>`
- Artefacts en cas d’échec : traces, captures, vidéo, logs `<À_ADAPTER>`
- Règle anti-flaky : ne jamais relancer silencieusement jusqu’au vert ; diagnostiquer ou isoler explicitement.

## 7. Sécurité

Pour un dépôt public GitHub, activer au minimum selon la compatibilité du projet :

- Dependabot alerts et mises à jour ;
- secret scanning et push protection ;
- code scanning, idéalement CodeQL default setup si les langages sont pris en charge ;
- protection de la branche principale et checks obligatoires.

Contrôles supplémentaires du projet :

- SCA : `<outil/commande>`
- SAST : `<outil/commande>`
- secrets : `<outil/commande>`
- conteneurs/IaC : `<outil/commande ou N/A>`
- SBOM : `<outil/commande ou N/A>`
- DAST : `<outil/commande ou N/A>`
- procédure de divulgation : `<SECURITY.md ou lien>`

Ne jamais placer de secret réel dans un prompt, une issue, un log, un fixture ou un dépôt.

## 8. Architecture

Avant une nouvelle abstraction :

1. rechercher le pattern existant ;
2. identifier les zones impactées et les tests voisins ;
3. comparer au moins le maintien de l’existant avec l’alternative ;
4. rendre explicites les compromis et la migration ;
5. obtenir la validation humaine si le choix est durable ou difficile à inverser.

Contraintes locales :

- limites de modules : `<À_ADAPTER>`
- dépendances autorisées/interdites : `<À_ADAPTER>`
- règles de compatibilité : `<À_ADAPTER>`
- exigences de performance : `<À_ADAPTER>`
- observabilité : `<À_ADAPTER>`

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
