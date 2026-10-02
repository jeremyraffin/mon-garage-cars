# 0001 — Séparer le Garage privé de la Vitrine publique

Statut : Accepted
Date : 2026-10-01

## Contexte

Le projet et son workflow IA doivent pouvoir être présentés publiquement, mais le Garage contient les photos et la collection réelle d’un enfant. L’Enfant ne possède pas de compte ; seuls les Parents disposent d’accès individuels permettant de modifier le Garage.

## Décision

Le Garage familial et ses données réelles restent privés. Une Vitrine distincte, alimentée par des données de démonstration, peut être publique. Le dépôt de code et la documentation du workflow peuvent également être publics.

La Vitrine occupe la racine publique du site (`/`). Le Garage privé est accessible sous `/garage` et ne révèle aucune donnée avant qu’une Session d’appareil ou une session Parent soit validée. La Vitrine utilise uniquement des données statiques explicitement approuvées et ne contacte jamais le backend du Garage.

## Alternatives considérées

- rendre le Garage public en lecture et protéger uniquement son édition ;
- partager le Garage au moyen d’un lien non indexé.

## Conséquences

- l’accès au Garage et les actions des Parents devront être protégés ;
- aucune donnée réelle du Garage ne devra être copiée automatiquement vers la Vitrine ;
- une compromission ou une erreur de configuration des données de démonstration ne doit pas ouvrir d’accès au backend privé ;
- l’Enfant utilisera le Garage sur un appareil disposant déjà d’un accès familial approprié, sans compte propre.

## Plan de validation ou de retour arrière

Valider les parcours d’accès Parent et Enfant pendant la spécification. La Vitrine pourra être supprimée sans migrer les données du Garage puisqu’elle restera indépendante.
