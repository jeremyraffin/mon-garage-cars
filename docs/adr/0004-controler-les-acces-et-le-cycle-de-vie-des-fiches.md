# 0004 — Contrôler les accès et le cycle de vie des Fiches

Statut : Accepted
Date : 2026-10-01

## Contexte

Le Garage familial est privé. Plusieurs adultes peuvent entretenir sa collection, tandis qu’un enfant de quatre ans doit pouvoir la consulter sur un appareil familial sans posséder de compte. Une erreur de manipulation, une session oubliée ou une modification simultanée ne doit ni exposer l’Espace Parent ni provoquer une perte silencieuse de données.

## Décision

### Accès adultes

- le Garage possède un Propriétaire initial ;
- le Propriétaire peut inviter ou retirer des Parents, gérer les sauvegardes et restaurations, et supprimer définitivement une Fiche archivée ;
- un Parent peut créer, valider, modifier et archiver des Fiches ;
- le Propriétaire autorise préalablement l’adresse Google d’un nouveau Parent ;
- l’invité doit accepter l’invitation en se connectant avec cette même adresse ;
- aucune connexion Google non invitée ne donne accès au Garage.

### Accès enfant

- un Parent active le Mode Enfant en s’authentifiant sur l’appareil familial ;
- l’application remplace ensuite la session Parent par une Session d’appareil en lecture seule ;
- la Session d’appareil expire après six mois, peut être renouvelée et peut être révoquée immédiatement depuis la liste des appareils ;
- le retour dans l’Espace Parent exige toujours une nouvelle authentification Google ;
- une Session d’appareil ne peut exécuter aucune mutation.

### Cycle de vie et concurrence

- retirer une Fiche du Garage l’archive sans supprimer sa photo ;
- une Fiche archivée peut être restaurée ;
- seul le Propriétaire peut déclencher sa suppression définitive, après une confirmation explicite ;
- chaque modification vérifie la version préalablement consultée et refuse un écrasement si la Fiche a changé entre-temps ;
- l’application conserve l’auteur et la date de la création, de la dernière modification, de la publication et de l’archivage ;
- aucun historique détaillé des interactions de l’Enfant et aucun outil d’analytics comportemental ne sont ajoutés.

## Alternatives considérées

- donner les mêmes pouvoirs à tous les Parents, écarté afin de limiter les opérations destructrices et la gestion des accès ;
- créer un compte pour l’Enfant, écarté car il n’en a pas besoin et que le projet ne doit stocker aucune information personnelle le concernant ;
- conserver une session Parent sur l’appareil familial derrière un simple bouton ou code local, écarté car cela exposerait les mutations à l’Enfant ;
- supprimer immédiatement une Fiche, écarté en raison du risque de perte accidentelle ;
- appliquer la dernière écriture reçue, écarté car elle pourrait écraser silencieusement la correction d’un autre Parent.

## Conséquences

- les politiques d’accès doivent distinguer Propriétaire, Parent et Session d’appareil ;
- la création, le renouvellement et la révocation des Sessions d’appareil sont des commandes sensibles ;
- les opérations Parent doivent être impossibles avec le seul jeton d’une Session d’appareil ;
- le stockage doit conserver les photos des Fiches archivées et les supprimer avec la Fiche lors d’une suppression définitive réussie ;
- le modèle de Fiche doit porter un état, une version et les métadonnées minimales de traçabilité ;
- la suppression définitive et la gestion des accès doivent être couvertes par la vérification de sécurité et une review indépendante.

## Plan de validation ou de retour arrière

Tester la matrice complète des rôles sur chaque lecture et commande, y compris les tentatives avec un compte Google non invité, une Session d’appareil expirée ou révoquée et une version de Fiche obsolète. Vérifier qu’une Fiche archivée est restaurable et qu’une suppression définitive ne laisse pas de photo orpheline.

Si la Session d’appareil ne peut pas être isolée de manière fiable de l’identité du Parent, suspendre le Mode Enfant authentifié et exiger une nouvelle décision avant toute mise en production.
