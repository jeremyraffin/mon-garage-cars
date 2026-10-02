# 0002 — Utiliser Supabase comme backend remplaçable

Statut : Accepted
Date : 2026-10-01

## Contexte

Le Garage doit stocker environ cent Fiches et leurs photos, proposer plusieurs accès Parent, protéger un Mode Enfant en lecture seule et, ultérieurement, autoriser un Assistant ChatGPT à créer des Brouillons. Le coût récurrent visé est nul, mais la collection ne doit pas dépendre de la pérennité d’une offre gratuite.

## Décision

Le MVP utilisera un projet Supabase hébergé dans une région précise de l’Union européenne pour Postgres, Auth, Storage et les règles d’autorisation par ligne. Le serveur OAuth 2.1 et une fonction MCP Supabase pourront être ajoutés lors de l’intégration de l’Assistant ChatGPT.

Supabase reste un composant remplaçable. La résilience repose obligatoirement sur trois mécanismes indépendants :

1. une Archive portable téléchargeable par un Parent après chaque session de modification ;
2. une sauvegarde technique hors site de la base et des fichiers au moyen de la CLI Supabase ;
3. un test de restauration depuis une instance vide avant la mise en production et après toute évolution du format d’archive.

Les migrations, politiques d’accès et configurations reproductibles sont conservées dans le dépôt. Les photos privées et sauvegardes réelles n’y sont jamais stockées.

## Alternatives considérées

- Firebase, écarté parce que son stockage nécessite un projet avec facturation activée ;
- une base et un stockage auto-hébergés, écartés à ce stade en raison du coût opérationnel et des sauvegardes à maintenir ;
- plusieurs services spécialisés, écartés pour limiter les intégrations et les frontières d’autorisation.

## Conséquences

- le projet accepte la suspension possible d’une instance gratuite peu active ;
- l’application doit détecter et expliquer une indisponibilité du backend ;
- les traitements d’image sont réalisés côté client ou dans du code maîtrisé, sans dépendre des transformations payantes de Supabase ;
- aucune mise en production n’est autorisée tant que l’export, la restauration et les politiques d’accès n’ont pas été vérifiés ;
- une migration vers un autre hébergeur reste possible à partir de l’Archive portable et du schéma versionné.

## Plan de validation ou de retour arrière

Restaurer un export dans un projet vide, comparer le nombre de Fiches et d’Œuvres, puis vérifier l’intégrité de chaque photo. Si cette restauration échoue ou si l’offre gratuite devient incompatible avec le projet, conserver le format d’archive et remplacer Supabase avant d’ajouter de nouvelles fonctions.
