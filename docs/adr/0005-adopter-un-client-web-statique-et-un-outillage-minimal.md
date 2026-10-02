# 0005 — Adopter un client web statique et un outillage minimal

Statut : Accepted
Date : 2026-10-02

## Contexte

Le Garage doit fonctionner sur téléphone, tablette et ordinateur, rester installable comme une application web et viser un coût récurrent nul. Le backend Supabase fournit déjà les capacités dynamiques ; le client n’a pas besoin de rendu serveur. Le dépôt est public et doit rester compréhensible, reproductible et peu chargé en dépendances.

## Décision

- développer une application monopage avec React, TypeScript et Vite ;
- utiliser npm et une version LTS de Node épinglée par le dépôt ;
- héberger les fichiers statiques sur Cloudflare Pages, initialement sous son domaine gratuit ;
- servir la Vitrine publique à la racine et le Garage privé sous `/garage` depuis la même application ;
- utiliser des variables CSS, des CSS Modules et un petit ensemble de composants accessibles, sans framework CSS ni bibliothèque générale de composants ;
- différer Storybook jusqu’à ce que le nombre d’états visuels ou le besoin de collaboration le justifie ;
- rendre le client installable dès le premier MVP, sans promettre de consultation hors connexion ;
- prendre en charge en priorité Safari sur iPhone et iPad, Chrome sur Android, puis les navigateurs de bureau modernes ;
- utiliser Vitest et Testing Library pour les tests unitaires et de composants, Playwright pour les parcours critiques, et pgTAP pour la base et les politiques RLS ;
- utiliser Docker Desktop pour exécuter la pile Supabase locale ;
- conserver un seul projet Supabase distant permanent pour la production et réserver le second emplacement gratuit à un staging temporaire si une évolution sensible l’exige.

Le développement reste dans un dépôt à paquet unique : `src/` contient le client, `supabase/` le backend versionné et `e2e/` les parcours transversaux. Un découpage de type monorepo ne sera envisagé qu’après l’apparition d’un second client autonome.

## Alternatives considérées

- Next.js et Vercel, écartés parce que le rendu serveur n’est pas nécessaire au MVP ;
- un backend applicatif distinct, écarté au profit des fonctions Supabase décrites par l’ADR 0003 ;
- un monorepo avec dossiers `frontend` et `backend`, écarté tant qu’une seule application est livrée ;
- pnpm, écarté car npm est déjà disponible et suffisant à cette échelle ;
- Podman Desktop, écarté car Docker est déjà familier au Propriétaire et limite les risques de compatibilité avec la pile Supabase ;
- un design system externe et Storybook dès le bootstrap, écartés pour limiter les dépendances et la maintenance initiales ;
- deux projets Supabase distants permanents, écartés afin de préserver un emplacement gratuit pour un autre besoin.

## Conséquences

- le routage du client et de l’hébergeur doit permettre un rechargement direct sous `/garage` ;
- la sécurité des données privées ne dépend jamais du caractère statique du site ni de son routage ;
- le design system initial est du code interne léger, documenté et testé avec ses composants ;
- les previews utilisent des données factices et ne se connectent pas à la production ;
- le développement local complet exige Docker Desktop en fonctionnement ;
- l’ajout d’une bibliothèque UI, de Storybook, d’un second paquet ou d’un projet Supabase permanent exige une nouvelle justification.

## Plan de validation ou de retour arrière

Vérifier le build statique, le routage direct vers la Vitrine et le Garage, l’installation sur un appareil mobile, les parcours Playwright sur Chromium et WebKit, puis les tests manuels sur au moins un appareil iOS/iPadOS et un appareil Android disponible.

Cloudflare Pages ne contient aucun état métier : le client peut être redéployé chez un autre hébergeur statique. Le contrat des composants reste indépendant des CSS Modules et peut être migré progressivement si le besoin évolue.
