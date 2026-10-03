# Règles de travail des agents

Ce projet suit l’`Agentic Software Engineering Workflow v0.1`. Lire aussi :

- `docs/agents/workflow.md` pour les règles propres au projet : environnements, langues, matrice de vérification, sécurité, contraintes d’architecture ;
- `docs/agents/models.md` pour l’affectation des rôles ;
- `docs/adr/` pour les décisions architecturales acceptées ;
- `CONTEXT.md` pour le langage du domaine, à employer dans le code, les issues et les specs ;
- `docs/specs/0001-premier-garage-utilisable.md` pour la spec du premier Garage utilisable ;
- `docs/agents/bootstrap-plan.md` pour le plan de bootstrap.

## 1. Classer avant d’agir

### FAST

Utiliser FAST uniquement si le changement est petit, local, évident, facilement réversible, sans logique critique, nouvelle dépendance ni décision architecturale.

### STANDARD

Chemin par défaut pour une feature, un bug non trivial, une logique métier, une modification d’API, un refactor cohérent ou une interaction utilisateur.

### HIGH-RISK

Utiliser HIGH-RISK dès qu’un changement touche notamment à l’authentification, aux permissions, aux données sensibles, aux secrets, au paiement, aux migrations, à l’infrastructure critique, à une intégration sensible, à une forte surface d’attaque ou à une décision architecturale durable.

En cas de doute, choisir le niveau supérieur et demander confirmation.

## 2. Human gates

Une validation humaine est requise avant :

- l’adoption d’une spec STANDARD multi-session ou HIGH-RISK ;
- une décision architecturale structurante ;
- l’ajout ou le remplacement d’une dépendance significative ;
- l’exécution d’une migration ou d’une opération difficilement réversible ;
- le merge d’un changement STANDARD ou HIGH-RISK.

## 3. Règles d’implémentation

- Travailler en petites tranches verticales observables.
- Respecter strictement la spec, le ticket et le out-of-scope.
- Réutiliser les patterns existants avant d’introduire une abstraction.
- Ne pas ajouter de dépendance sans approbation.
- Ne pas modifier `AGENTS.md`, le workflow ou les skills pendant une tâche d’implémentation.
- Ne pas neutraliser un test, un contrôle ou une règle pour obtenir artificiellement du vert.
- Ajouter ou mettre à jour les tests proportionnellement au risque.
- Conserver les changements de l’utilisateur qui ne font pas partie du scope.

## 4. Escalade

Après **deux échecs significatifs consécutifs**, arrêter l’approche en cours :

1. expliquer les tentatives et les preuves obtenues ;
2. préciser l’hypothèse probablement fausse ;
3. proposer des options avec leurs compromis ;
4. laisser l’humain décider.

Escalader aussi si le scope dérive, si la spec paraît incorrecte, si une dépendance ou une décision architecturale devient nécessaire, si une hypothèse majeure est invalidée ou si le ticket ne tient plus dans une session raisonnable.

## 5. Vérification obligatoire

Ne jamais déclarer une tâche terminée sans exécuter la commande adaptée et rapporter son résultat.

```bash
# FAST — format et lint
npm run verify:fast

# STANDARD — verify:fast, types, tests, pgTAP, build et E2E
npm run verify

# HIGH-RISK ou changement sensible — verify, audit, secrets, contrôles du build
npm run verify:security
```

Prérequis et contenu des commandes : `docs/agents/workflow.md`, section 5. Si une vérification ne peut pas être exécutée, le signaler explicitement avec la raison et le risque résiduel.

## 6. Review indépendante

- STANDARD et HIGH-RISK exigent une review distincte de l’implémentation.
- Utiliser si possible un modèle différent pour réduire les angles morts corrélés.
- Le reviewer reçoit la spec approuvée, le diff, les tests, les résultats de vérification et les conventions utiles.
- Les findings sont classés `BLOCKING`, `IMPORTANT` ou `SUGGESTION`.
- Le reviewer ne valide pas sur la seule base du résumé de l’implémenteur.

## 7. Git et GitHub

- Un commit représente un changement logique cohérent.
- Utiliser Conventional Commits : `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`.
- Lier la PR à l’issue ou au ticket lorsqu’il existe.
- Ne pas pousser directement sur la branche protégée.
- Le merge par squash est la convention par défaut, sauf règle projet contraire.

## 8. Fin de tâche

Le compte rendu final contient :

- ce qui a changé ;
- les fichiers ou comportements importants ;
- les vérifications exécutées et leur résultat ;
- les risques, limites ou décisions encore ouvertes ;
- le lien vers la PR ou l’issue si applicable.

## Agent skills

### Issue tracker

Issues et specs sur GitHub Issues (`jeremyraffin/mon-garage-cars`, CLI `gh`). See `docs/agents/issue-tracker.md`.

### Triage labels

Vocabulaire par défaut (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context : un `CONTEXT.md` + `docs/adr/` à la racine. See `docs/agents/domain.md`.
