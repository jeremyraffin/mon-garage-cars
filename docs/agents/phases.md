# Phases et passages de relais

Lire ce document lorsqu’une tâche démarre, change de phase ou hésite sur le prochain rôle. L’affectation courante des modèles aux rôles reste définie dans `models.md`.

## Règle de transition

Une phase se termine uniquement lorsque son critère de sortie est observable. Avant le passage de relais, le rôle conducteur publie un **handoff** contenant :

1. la source approuvée : demande, issue, spec ou ADR ;
2. le résultat produit et les preuves de vérification ;
3. les décisions ouvertes, risques et éléments hors périmètre ;
4. la prochaine phase et le rôle attendu.

Le rôle suivant vérifie ce handoff avant d’agir. Une entrée manquante renvoie la tâche à la phase précédente ; elle n’est pas complétée par supposition. Avant l’ouverture d’une PR, un human gate est matérialisé dans la demande ou l’issue qui porte la tâche. Dès qu’une PR existe, les preuves, reviews et validations humaines suivent `evidence.md`, et toute décision antérieure durable y est transcrite.

## Carte des phases

| Phase | Quand y entrer | Rôle conducteur | Sortie attendue | Critère de sortie | Suite |
|---|---|---|---|---|---|
| 0. Intake et risque | nouvelle demande | Product / Spec ; Implementation seulement pour un FAST évident | scope initial, risque, inconnues ; pour FAST, micro-spec dans la demande ou l’issue | niveau justifié et, pour FAST, résultat attendu, hors périmètre et vérification nommés | Discovery ou Spec ; Implementation pour un FAST cadré |
| 1. Discovery | besoin ambigu, nouveau produit ou changement significatif | Product / Spec avec `$grill-with-docs` | décisions, vocabulaire et scénarios limites | toutes les décisions accessibles ont une réponse, aucune branche n’est silencieusement supposée et l’humain confirme la compréhension | Architecture si décision durable, sinon Spec |
| 2. Architecture / Exploration | frontières, dépendances ou choix difficiles à inverser | Architecture / Exploration | existant cartographié, options, compromis, rollback, ADR proposé si nécessaire | option retenue et décision structurante validée | Spec |
| 3. Spec | résultat à rendre falsifiable | Product / Spec, éventuellement `$to-spec` | résultat attendu, critères d’acceptation, hors périmètre, risque confirmé | spec acceptée et dépendances connues | Tickets si multi-session, sinon Implementation |
| 4. Tickets | effort trop grand pour une session | Product / Spec avec Architecture, éventuellement `$to-tickets` | tranches verticales ordonnées et blocages explicites | chaque ticket est démontrable, falsifiable et session-sized | Implementation du premier ticket prêt |
| 5. Implementation | ticket ou micro-spec approuvé | Implementation, éventuellement `$implement` | changement observable et tests proportionnés au risque | scope satisfait sans décision ouverte cachée | Verification |
| 6. Verification | implémentation candidate | Implementation | sorties du harness et limites résiduelles | commande adaptée verte, ou impossibilité explicitée avec son risque | FAST vers handoff humain ; STANDARD/HIGH-RISK vers Review |
| 7. Review indépendante | diff STANDARD ou HIGH-RISK vérifié | Code Review avec `$code-review` ; Security Review si la surface le justifie | rapports couvrant les axes requis, findings et preuves publiés dans la PR | chaque axe requis est examiné et chaque finding classé `BLOCKING`, `IMPORTANT` ou `SUGGESTION` | Corrections si un `BLOCKING` ou `IMPORTANT` reste ouvert ; sinon Human gate avec les suggestions enregistrées |
| 8. Corrections | finding à traiter | Implementation, distinct du reviewer | correction ciblée et nouvelles preuves | vérification verte et finding résolu ou accepté explicitement | retour en Review |
| 9. Human gate et merge | candidat revu, checks verts | humain ; l’agent peut préparer la PR avec `$pr` | décision durable d’approuver, refuser ou demander des changements | approbation et risques résiduels enregistrés | Merge puis Release |
| 10. Release | merge produisant un état livré | humain en v0.1 | déploiement contrôlé et rollback connu | smoke tests critiques réussis | Retro si signal utile, sinon prochain ticket |
| 11. Retro | incident, friction récurrente ou jalon significatif | Retro / Steering avec `$retro` | peu d’actions mesurables, chacune avec propriétaire ou déclencheur | actions enregistrées dans le backlog ou le guide | Intake |

Le même agent peut tenir plusieurs rôles successifs lorsque l’indépendance n’est pas requise. L’implémentation et la review restent séparées sur STANDARD et HIGH-RISK.

## Chemins par niveau de risque

```text
FAST
Intake → micro-spec → Implementation → Verification → handoff humain

STANDARD
Intake → Discovery si utile → Spec → human gate si significatif
→ Implementation → Verification → Review → Corrections ↺ → human gate → merge

HIGH-RISK
Intake → Discovery → Architecture / Exploration → Spec + analyse de risque
→ human gate → Tickets → Implementation → Verification complète
→ Code Review + Security Review → Corrections ↺ → human gate → merge → Release
```

Une tâche monte de niveau dès que sa surface réelle l’exige. Elle ne redescend qu’après une décision humaine enregistrée.

## Passage spécifique au bootstrap

Le bootstrap suit une séquence explicite :

1. Product / Spec produit le plan et obtient son adoption humaine.
2. L’agent de bootstrap implémente uniquement ce plan et conserve `BOOTSTRAP_REQUIRED`.
3. Implementation exécute le harness et complète la matrice locale, CI et distante de `evidence.md` ; Code Review publie son rapport, complété par Security Review si la surface le justifie.
4. Implementation traite les findings puis repasse par Verification et Review.
5. L’humain autorise explicitement le retrait de `BOOTSTRAP_REQUIRED`.
6. L’agent de bootstrap retire le verrou dans un dernier changement ciblé et réexécute la vérification pertinente.
7. L’humain autorise le merge après lecture du diff final et des preuves.

Le bootstrap est prêt au merge lorsque le verrou est absent de la branche validée, que les preuves sont durables dans la PR et que le merge est autorisé. Il est terminé seulement après le merge, les smoke tests et la fermeture de l’issue. Une mention de fin dans le README ou le résumé de l’implémenteur ne remplace pas ces preuves.

### États observables du bootstrap

| État | Preuve observable | Rôle suivant |
|---|---|---|
| `BOOTSTRAP_REQUIRED` | verrou présent ; plan absent, non adopté ou en cours d’exécution | Product / Spec, puis agent de bootstrap après adoption |
| `BOOTSTRAP_READY_FOR_REVIEW` | plan exécuté, harness vert, PR ouverte, verrou présent | Code Review ; Security Review si nécessaire |
| `BOOTSTRAP_REVIEW_HANDLED` | rapports publiés, vérification repassée, aucun `BLOCKING` ou `IMPORTANT` non résolu, verrou présent | humain |
| `BOOTSTRAP_UNLOCK_AUTHORIZED` | commentaire ou approbation humaine dans la PR autorisant explicitement le retrait | agent de bootstrap |
| `BOOTSTRAP_UNLOCKED` | verrou absent du diff final et vérification pertinente verte | humain pour autorisation de merge |
| `BOOTSTRAP_COMPLETE` | PR mergée, smoke tests réussis et issue fermée | Retro si signal utile, sinon prochaine tâche produit |

## Routage rapide

- Idée encore floue → Product / Spec.
- Choix technique durable ou frontière incertaine → Architecture / Exploration.
- Spec ou ticket approuvé → Implementation.
- Diff vérifié → Code Review, puis Security Review si nécessaire.
- Findings ouverts → Implementation, puis retour au reviewer.
- Candidat vert et revu → humain.
- Friction récurrente ou jalon terminé → Retro / Steering.
