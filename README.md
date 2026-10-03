# Mon Garage Cars

Catalogue visuel et sonore des miniatures de l'univers des films _Cars_ que possède un enfant. L'enfant explore le Garage ; les parents en entretiennent le contenu. Projet personnel, non commercial, sans affiliation avec Disney ou Pixar.

## Statut

Bootstrap technique en cours (issue #2). Le dépôt contient une coquille neutre : aucune fonctionnalité produit n'est encore implémentée.

## Périmètre

- **Garage** : collection privée, réservée aux Parents et aux appareils familiaux autorisés. Ses données réelles ne sont jamais dans ce dépôt.
- **Vitrine** : collection de démonstration publique, à la racine du site (`/`), alimentée uniquement par des données explicitement approuvées.

Spec du premier Garage utilisable : [`docs/specs/0001-premier-garage-utilisable.md`](docs/specs/0001-premier-garage-utilisable.md). Vocabulaire du domaine : [`CONTEXT.md`](CONTEXT.md).

## Décisions d'architecture

- [0001 — Séparer le Garage privé de la Vitrine publique](docs/adr/0001-separer-le-garage-prive-de-la-vitrine-publique.md)
- [0002 — Utiliser Supabase comme backend remplaçable](docs/adr/0002-utiliser-supabase-comme-backend-remplacable.md)
- [0003 — Séparer lectures et commandes métier](docs/adr/0003-separer-lectures-et-commandes-metier.md)
- [0004 — Contrôler les accès et le cycle de vie des Fiches](docs/adr/0004-controler-les-acces-et-le-cycle-de-vie-des-fiches.md)
- [0005 — Adopter un client web statique et un outillage minimal](docs/adr/0005-adopter-un-client-web-statique-et-un-outillage-minimal.md)

## Démarrage local

Prérequis : Node 24.15 ou plus récent (version de référence dans `.nvmrc`), npm et, pour la base de données, Docker Desktop démarré.

```bash
npm ci
npm run dev          # client sur http://localhost:5173
```

Routes de la coquille : `/` (Vitrine) et `/garage`.

### Base de données locale

```bash
npm run db:start     # démarre la pile Supabase locale
npm run db:test      # tests pgTAP
npm run db:stop      # arrête la pile
```

Détails : [`supabase/README.md`](supabase/README.md). La pile locale n'est liée à aucun projet distant.

### Variables d'environnement

Copier `.env.example` vers `.env.local` pour un usage local. Ces fichiers ne sont jamais suivis par Git. Aucune clé secrète n'est destinée au navigateur.

## Vérification

| Commande                  | Contenu                                                                                   |
| ------------------------- | ----------------------------------------------------------------------------------------- |
| `npm run verify:fast`     | format et lint                                                                            |
| `npm run verify`          | `verify:fast`, types, tests unitaires, base de données, build, E2E Chromium et WebKit     |
| `npm run verify:security` | `verify`, audit des dépendances, détection de secrets, contrôles de sécurité sur le build |

Prérequis : `npm run e2e:install` (navigateurs Playwright) et Docker Desktop pour `db:test`.

Hook Git facultatif, qui appelle uniquement `verify:fast` : `npm run hooks:install`. Il ne remplace pas la CI.

## Ce qui peut être publié

Le code et la documentation du workflow sont publics. Ne sont **jamais** ajoutés au dépôt : les photos des miniatures, les descriptions réelles du Garage, les sauvegardes, les secrets et le prototype d'origine. Seules les Fiches et photos explicitement approuvées pour la Vitrine peuvent être publiées. Voir [`NOTICE`](NOTICE).

## Sécurité

Voir [`SECURITY.md`](SECURITY.md).

## Licence

Code sous licence MIT ([`LICENSE`](LICENSE)). Les photos et données de démonstration en sont exclues ([`NOTICE`](NOTICE)).
