# Affectation des modèles aux rôles

Ce document décrit les capacités attendues et fige l’affectation v0.1 déjà validée. Il est copié tel quel dans un nouveau projet : aucune sélection de modèle n’est demandée pendant le bootstrap.

## Principes

- Utiliser la matrice v0.1 par défaut dans tous les nouveaux projets.
- Réserver le raisonnement profond aux décisions ambiguës, transversales ou risquées.
- Sur STANDARD et HIGH-RISK, l’implémentation et la review utilisent des modèles différents.
- Ne jamais réduire un human gate parce qu’un modèle paraît plus performant.
- Ne modifier cette matrice qu’après une rétro fondée sur des tâches réelles, ou si un modèle devient indisponible.

## Matrice des capacités

| Rôle | Capacités prioritaires | Contexte requis | Écrit du code ? | Sortie attendue |
|---|---|---|---:|---|
| Spec | clarification, synthèse, critères falsifiables, détection d’ambiguïtés | besoin, domaine, contraintes | Non | décisions + spec |
| Architecture | exploration de repo, systèmes, compromis, risques | code et docs pertinents | Non | options + recommandation + ADR proposé |
| Implementation | exactitude, édition outillée, tests, discipline de scope | ticket approuvé + règles projet | Oui | code + tests + preuves |
| Review | raisonnement adversarial, lecture de diff, correctness, maintenabilité | spec + diff + résultats | Non | findings priorisés |
| Security | threat modeling, auth, données, dépendances, abus | surfaces exposées + diff + scans | Non | risques + remédiations |
| Retro | synthèse multi-artefacts, causalité, amélioration de processus | issues, PR, incidents, métriques | Non | actions mesurables |

## Affectation v0.1

| Rôle | Modèle / environnement | Effort par défaut | Quand l’utiliser |
|---|---|---|---|
| Product / Spec | ChatGPT — GPT-5.6 Sol | High | grill, arbitrages, spec et critères d’acceptation |
| Architecture / Exploration | ChatGPT ou Codex — GPT-5.6 Sol | High | exploration du dépôt, options, risques et ADR |
| Implementation | Claude Code — Sonnet 5.5 | Medium | FAST et STANDARD bien cadrés |
| Implementation complexe | Claude Code — Opus 5.5 | High | escalade validée pour problème transversal ou difficile |
| Code Review | Codex — GPT-5.6 Sol | High | review indépendante du diff sur STANDARD/HIGH-RISK |
| Security Review | Codex — GPT-5.6 Sol | High | uniquement lorsque le risque le justifie |
| Retro / Steering | ChatGPT — GPT-5.6 Sol | High | rétro et amélioration du workflow |
| Release | Phase 2 — non affecté | — | le rôle reste humain en v0.1 |

### Règles d’escalade

- Sonnet 5.5 reste le modèle d’implémentation par défaut.
- Opus 5.5 n’est utilisé qu’après validation humaine si la tâche est complexe, transversale ou résiste à l’approche normale.
- GPT-5.6 Sol reste le reviewer même lorsque l’implémentation passe à Opus afin de conserver l’indépendance de fournisseur.
- Security Review n’est pas une étape obligatoire sur FAST et n’est ajoutée sur STANDARD que si la surface le justifie.
- Si un modèle n’est pas disponible, arrêter le dispatch et documenter temporairement son remplaçant ; ne pas réécrire toute la matrice dans l’urgence.

### Passage entre les outils

En v0.1, le routage reste manuel :

```text
Claude Code / Sonnet 5.5
→ implémentation + tests + résultats du harness
→ transmission de la spec et du diff
→ Codex / GPT-5.6 Sol
→ review indépendante
→ validation humaine
```

Claude Code n’est pas supposé lancer Codex automatiquement, et Codex n’est pas supposé lancer Claude Code. Une orchestration automatique pourra être évaluée en phase 2.

## Contrat par rôle

### Spec

- Ne décide pas silencieusement à la place de l’humain.
- Distingue faits, hypothèses, décisions et questions ouvertes.
- Produit des critères qui peuvent réellement échouer avant l’implémentation.

### Architecture

- Cartographie l’existant avant de proposer du nouveau.
- Compare les alternatives et les coûts de migration/rollback.
- N’implémente pas pendant l’exploration.

### Implementation

- Suit un ticket approuvé et des tranches verticales.
- Vérifie chaque étape importante.
- S’arrête après deux échecs significatifs ou lors d’une dérive de scope.

### Review

- Cherche activement les écarts à la spec, régressions, cas limites et risques.
- Ne modifie pas directement le code.
- Cite des emplacements et propose un moyen de vérifier chaque finding.

### Security

- Complète les scanners ; ne les remplace pas.
- Priorise exploitabilité, impact et vraisemblance.
- Vérifie notamment frontières de confiance, permissions, secrets, données et dépendances.

### Retro

- Sépare incident ponctuel et signal récurrent.
- Propose peu d’actions, avec responsable, échéance ou déclencheur et critère de succès.
- Ne crée une nouvelle règle ou skill qu’après preuve de récurrence.

## Révision de la matrice

Ne pas réévaluer les modèles pendant le bootstrap. Ouvrir une révision seulement :

- après au moins trois tâches STANDARD terminées ;
- après un échec récurrent attribuable au modèle ;
- si coût, latence ou disponibilité deviennent problématiques ;
- lors du passage à la phase 2 pour le Release Agent.

Procédure :

1. rejouer un petit jeu de tâches représentatives ;
2. mesurer réussite, corrections humaines, temps, coût et findings manqués ;
3. comparer à la configuration précédente ;
4. modifier une affectation à la fois ;
5. documenter la décision dans ce fichier.

## Journal des changements

| Date | Rôle | Avant | Après | Motif | Résultat attendu |
|---|---|---|---|---|---|
| `2026-10-01` | Tous | Configuration initiale | Matrice v0.1 | Décision du workflow | Base à évaluer après trois tâches STANDARD |
