# 0001 — Premier Garage utilisable

Statut : Accepted
Date : 2026-10-02
Validation humaine : 2026-10-02
Risque : HIGH-RISK
Propriétaire des décisions : Jérémy Raffin

## Résultat attendu

Livrer une application web responsive en français qui permet à un enfant de quatre ans de parcourir visuellement les Miniatures Cars qu’il possède et d’écouter leur nom et leur description. Les Parents entretiennent le Garage privé ; une Vitrine distincte présente publiquement le projet avec des données de démonstration.

La première version doit rester utilisable sans reconnaissance d’image ni service d’IA payant.

## Références obligatoires

- le langage du domaine est défini dans `GLOSSARY.md` ;
- la séparation entre Garage et Vitrine est définie par l’ADR 0001 ;
- Supabase et la stratégie de sauvegarde sont définis par l’ADR 0002 ;
- la frontière entre lectures et commandes est définie par l’ADR 0003 ;
- les rôles et le cycle de vie sont définis par l’ADR 0004 ;
- le client web et l’outillage sont définis par l’ADR 0005.

## Utilisateurs et accès

### Enfant

- utilise le Mode Enfant sans compte ni information personnelle ;
- accède au Garage au moyen d’une Session d’appareil en lecture seule, valable six mois et révocable ;
- ne voit aucune commande de modification ;
- doit pouvoir parcourir la galerie avec l’aide initiale d’un adulte.

### Parent

- accède avec une adresse Google préalablement invitée ;
- crée et complète des Brouillons ;
- publie, modifie, archive et restaure des Fiches ;
- doit se réauthentifier pour entrer dans l’Espace Parent depuis un appareil en Mode Enfant.

### Propriétaire

- possède les capacités d’un Parent ;
- invite ou retire d’autres Parents ;
- gère les Sessions d’appareil, sauvegardes et restaurations ;
- peut supprimer définitivement une Fiche archivée après confirmation explicite.

## Données métier

Une Variante visuellement distincte possède sa propre Fiche. Les exemplaires strictement identiques ne sont pas comptés plusieurs fois.

Une Fiche publiée exige :

- une photo de la miniature réellement possédée ;
- son nom français ;
- une couleur principale ;
- une description française de une à deux phrases, environ vingt à quarante mots, chaleureuse, factuelle et adaptée à un enfant.

Elle peut aussi contenir :

- un numéro sous forme de texte ;
- une équipe ou affiliation ;
- une ou plusieurs Œuvres de l’univers *Cars*.

Un Brouillon peut être enregistré avec sa seule photo. Une information incertaine reste vide. La publication exige une validation humaine de tous les champs obligatoires.

Chaque Fiche porte son état, sa version et l’auteur et la date de sa création, dernière modification, publication et archivage.

## Photos

- le navigateur propose recadrage et rotation, corrige légèrement la lumière, réencode l’image et retire ses métadonnées avant l’envoi ;
- le traitement ne modifie pas générativement la miniature ;
- le Garage conserve un master optimisé d’environ 2 000 pixels ainsi qu’une miniature adaptée à la galerie ;
- un arrière-plan contenant une personne ou une information privée déclenche un avertissement au Parent ;
- remplacer une photo supprime l’ancienne après la réussite complète de l’opération ;
- l’Archive portable constitue le filet de récupération ;
- les anciennes photos du prototype n’empêchent pas l’import et pourront être remplacées progressivement sur décision humaine.

## Parcours

### Vitrine publique

- `/` affiche « Mon Garage de Miniatures » à partir de données statiques explicitement approuvées ;
- six à dix Fiches de démonstration sont indépendantes du Garage et ne sont jamais synchronisées ;
- un bouton mène à `/garage` ;
- la page indique qu’il s’agit d’un projet personnel, non commercial et sans affiliation avec Disney/Pixar ;
- aucun logo, affiche ou visuel officiel récupéré n’est utilisé.

### Arrivée dans le Garage

- une Session d’appareil valide ouvre immédiatement la galerie ;
- sans session, aucune donnée privée n’apparaît et l’écran propose d’activer le Mode Enfant ou d’ouvrir l’Espace Parent ;
- une icône discrète mais visible permet de demander l’accès Parent et conduit toujours à une authentification Google.

### Création manuelle

1. le Parent choisit ou prend une photo ;
2. le traitement local prépare l’image ;
3. un Brouillon est créé ;
4. le Parent complète et valide les champs ;
5. les ressemblances éventuelles sont présentées sans blocage automatique ;
6. la publication rend la Fiche visible dans le Mode Enfant.

### Galerie enfant

- les Fiches sont triées par nom français ;
- un badge « Nouveau » peut signaler temporairement les ajouts récents ;
- aucune pagination ni filtre n’est présent dans le premier MVP ;
- chaque carte montre principalement la photo, puis le nom, le numéro éventuel et un accent de couleur ;
- l’équipe et les Œuvres restent dans le détail.

### Détail et lecture

- le détail occupe tout l’écran sur mobile et une grande fenêtre sur les écrans plus larges ;
- l’ouverture prononce le nom une seule fois ;
- des commandes permettent de répéter le nom, lire la description et fermer ;
- démarrer une lecture, changer de Fiche ou fermer le détail arrête la lecture précédente ;
- le retour du navigateur ferme d’abord le détail et restaure la position dans la galerie.

### Archivage et concurrence

- archiver retire la Fiche du Garage tout en permettant sa restauration ;
- la suppression définitive est réservée au Propriétaire ;
- une modification fondée sur une version devenue obsolète est refusée et la version récente est présentée.

### Indisponibilité

- le Mode Enfant affiche un message rassurant et une grande action « Réessayer » ;
- l’Espace Parent peut afficher un diagnostic technique plus précis ;
- aucune consultation hors connexion n’est promise dans cette version.

## Sécurité et confidentialité

- le navigateur ne contient aucune clé secrète ;
- les lectures autorisées utilisent Supabase sous droits SQL et RLS ;
- les mutations passent par l’API applicative des Edge Functions ;
- les capacités de Propriétaire, Parent et Session d’appareil sont testées positivement et négativement ;
- le projet ne stocke aucun compte, nom, photo ni donnée d’usage concernant l’Enfant ;
- aucun analytics comportemental n’est installé ;
- aucune photo ou description privée n’est envoyée à un outil tiers d’observabilité ;
- les journaux techniques excluent les photos, descriptions, jetons et secrets.

## Accessibilité et compatibilité

- les zones tactiles mesurent au moins 48 × 48 pixels ;
- le contraste vise WCAG AA ;
- le clavier et les lecteurs d’écran permettent tous les parcours pertinents ;
- aucune information n’est transmise uniquement par la couleur ou le son ;
- les préférences de réduction des mouvements sont respectées ;
- les tests automatisés couvrent Chromium et WebKit ;
- une validation manuelle est réalisée sur Safari iPhone/iPad et Chrome Android lorsque les appareils sont disponibles.

## Sauvegarde et restauration

L’Archive portable contient :

```text
manifest.json
fiches.json
oeuvres.json
photos/<fiche-id>/master.jpg
```

Elle ne contient aucun secret ni donnée d’authentification. Un Parent la télécharge après une session de modification et la conserve dans son espace cloud privé. Une sauvegarde technique de la base et du Storage est réalisée hors site. La restauration depuis une instance vide doit réussir avant la production et après toute évolution du format.

## Import initial

Les quatorze entrées du prototype HTML fourni sont importées comme Brouillons à vérifier. Le fichier HTML original, ses images encodées et les photos privées ne sont pas ajoutés au dépôt public. Aucune entrée n’est publiée automatiquement.

## Critères de succès

- un Parent peut publier une nouvelle Miniature sans aide technique ;
- un Enfant guidé peut retrouver une carte, écouter le nom et la description, puis revenir à la galerie ;
- aucun rôle ne peut lire ou modifier davantage que ses permissions ;
- une Session d’appareil expirée ou révoquée ne donne plus accès au Garage ;
- une Archive portable restaure toutes les Fiches, Œuvres et photos ;
- les parcours critiques fonctionnent sur les appareils ciblés ;
- les quatorze Brouillons importés peuvent être vérifiés progressivement sans remplacement immédiat obligatoire de leurs photos.

## Hors périmètre

- Assistant ChatGPT, reconnaissance photo et génération intégrée ;
- publication automatique d’un résultat d’IA ;
- prononciation personnalisée des noms ;
- filtres, recherche, favoris, statistiques et pagination ;
- consultation hors connexion ;
- Storybook ;
- analytics ;
- comptes Enfant, inscription publique et Garages publics multiples ;
- domaine personnalisé et monétisation.

## Tranches prévues

0. bootstrap technique, CI, sécurité et déploiement d’une coquille neutre ;
1. Vitrine publique minimale et fondations visuelles ;
2. modèle de données, sauvegarde, restauration et matrice RLS ;
3. authentification Parent et gestion des accès ;
4. saisie manuelle, traitement des photos et cycle des Fiches ;
5. Mode Enfant, voix, installation et Session d’appareil ;
6. import du prototype, essais sur appareils réels et durcissement.

Chaque tranche devient une sous-issue de l’issue de spec. Elle possède ses propres critères d’acceptation, sa classification de risque et son human gate avant implémentation.

## Évolutions envisagées

1. Assistant ChatGPT limité à la recherche et à la création confirmée de Brouillons ;
2. affichage minimal des références et incertitudes, sans score complexe par champ ;
3. champ facultatif de prononciation après essais des voix réelles ;
4. lecture hors connexion de la dernière collection synchronisée ;
5. filtres visuels si la collection rend leur utilité observable ;
6. reconnaissance intégrée uniquement si une solution sans coût récurrent réussit le benchmark approuvé.
