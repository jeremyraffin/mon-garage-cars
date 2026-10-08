Closes #<numéro> <!-- ou « Refs #<numéro> » si la PR ne termine pas l'issue -->

## Summary

<!-- Résultat observable, pourquoi ce changement existe (spec ou ticket, hors-périmètre respecté) et fichiers ou comportements importants. -->

## Evidence

<!-- Chaque preuve nomme le point fixe qu'elle couvre (SHA du commit). Cocher uniquement ce qui a réellement été exécuté. Voir docs/agents/evidence.md. -->

- [ ] `npm run verify:fast`
- [ ] `npm run verify` (STANDARD)
- [ ] `npm run verify:security` (HIGH-RISK)

| Layer  | Status                | Evidence                                        |
| ------ | --------------------- | ----------------------------------------------- |
| Local  | `<PASS / FAIL / N/A>` | `<commandes, point fixe, résultats>`            |
| CI     | `<PASS / FAIL / N/A>` | `<checks sur le même point fixe>`               |
| Remote | `<PASS / FAIL / N/A>` | `<réglages, preview Cloudflare ou smoke tests>` |

## Independent review

<!-- Requise pour STANDARD et HIGH-RISK. -->

- Reviewer and independence: `<reviewer, rôle, raison de l'indépendance / N/A avec raison>`
- Fixed point reviewed: `<commit ou plage de diff>`
- Findings and dispositions: `<lien vers la review durable>`

## Risks

<!-- Risques résiduels, limites connues, rollback, décisions encore ouvertes, prérequis humains et éléments hors périmètre. -->

## Handoff

- Next phase and role: `<phase et rôle attendus selon docs/agents/phases.md>`
- Expected action: `<ce que le rôle suivant doit faire>`
- Open decisions: `<décisions ouvertes / aucune>`

## Merge Danger

**Door:** <!-- one-way ou two-way : le merge est-il réversible sans migration ni intervention manuelle ? -->

**Blast Radius:** <!-- un mot : docs, client, CI, base, production... -->

<!-- Optionnel : conséquences possibles du merge. -->

## Human gate

- Requirement: `<required / not required avec raison>`
- Decision: `<lien vers la décision explicite / pending / N/A>`

## Closure

- [ ] le commit candidat est identifié ;
- [ ] les preuves locales couvrent ce commit ;
- [ ] les checks CI requis couvrent ce commit ;
- [ ] les surfaces distantes sont vérifiées ou justifiées `N/A` ;
- [ ] les findings `BLOCKING` et `IMPORTANT` sont résolus ;
- [ ] le human gate requis est enregistré ;
- [ ] le smoke test post-merge possède un contrôle et un responsable nommés.
