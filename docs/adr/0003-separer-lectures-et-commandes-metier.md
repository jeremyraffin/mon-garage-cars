# 0003 — Séparer les lectures des commandes métier

Statut : Accepted
Date : 2026-10-01

## Contexte

Le Garage sera utilisé depuis une application web puis, dans une itération ultérieure, depuis un Assistant ChatGPT. Les deux clients devront respecter les mêmes règles pour créer un Brouillon, publier ou modifier une Fiche, gérer les Parents et créer une Session d’appareil.

Supabase permet un accès sécurisé depuis un navigateur au moyen d’une clé publiable, de l’identité de l’utilisateur et des politiques d’autorisation par ligne. Faire transiter toutes les requêtes par un serveur supplémentaire augmenterait la complexité sans rendre, à lui seul, l’accès plus privé. À l’inverse, laisser chaque client orchestrer les mutations disperserait les règles métier.

## Décision

L’application adopte une architecture hybride :

- les lectures autorisées passent directement du client vers les API Supabase et restent protégées par les droits et politiques RLS ;
- les mutations métier passent par une API applicative constituée de Supabase Edge Functions TypeScript ;
- l’Espace Parent et l’Assistant ChatGPT utilisent les mêmes commandes métier, avec des capacités différentes ;
- chaque commande authentifie l’appelant, vérifie ses permissions, valide les données reçues et applique les transitions autorisées ;
- les contraintes de base de données et les politiques RLS restent actives comme protections indépendantes lorsque le contexte d’exécution le permet ;
- une clé secrète n’est utilisable que dans un composant serveur maîtrisé et n’est jamais transmise au navigateur ni enregistrée dans le dépôt ;
- les photos sont préparées côté client. Leur transfert vers le stockage privé utilise un droit d’envoi précisément limité, sans faire transiter inutilement leurs octets par l’API applicative.

Le détail des droits directs, des commandes et des politiques RLS devra être approuvé dans la spec de sécurité avant l’implémentation.

## Alternatives considérées

- accès direct à Supabase pour les lectures et les écritures, écarté afin de ne pas dupliquer les règles de mutation entre le web et l’Assistant ChatGPT ;
- backend intermédiaire pour toutes les opérations, écarté car il dupliquerait inutilement la Data API pour les lectures simples ;
- serveur applicatif dédié, écarté à ce stade au profit des Edge Functions déjà intégrées au backend retenu.

## Conséquences

- les lectures du Mode Enfant restent simples et rapides ;
- les mutations disposent d’un contrat commun, testable et réutilisable ;
- l’API applicative est publiquement joignable et ne doit jamais être considérée comme sûre par simple dissimulation ;
- les politiques RLS, droits SQL, validations de commandes et accès Storage deviennent des éléments critiques de la vérification de sécurité ;
- les commandes doivent être conçues de manière idempotente lorsqu’une répétition réseau pourrait créer un doublon ou appliquer deux fois une action ;
- aucune mutation nouvelle ne peut contourner l’API applicative sans une nouvelle décision explicite.

## Plan de validation ou de retour arrière

Tester chaque rôle contre les lectures et mutations autorisées et interdites, notamment sans session, avec une Session d’appareil, avec un Parent membre d’un autre Garage et via l’Assistant ChatGPT. Vérifier qu’aucune clé secrète n’est présente dans les artefacts frontend.

Si la couche Edge Functions devient indisponible ou trop contraignante, conserver le contrat des commandes et le porter vers un autre runtime TypeScript sans modifier le modèle de données ni les droits de lecture.
