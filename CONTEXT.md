# Mon Garage Cars

Mon Garage Cars est un catalogue visuel et sonore des miniatures issues de l’univers des films *Cars* que possède un enfant. L’enfant explore le garage ; les parents en entretiennent le contenu.

## Langage

**Garage** :
La collection numérique des miniatures Cars enregistrées dans l’application.
_Éviter_ : inventaire, stock

**Miniature Cars** :
Un jouet physique issu de l’univers *Cars* et possédé par l’enfant. Chaque variante identifiable possède sa propre Fiche ; les exemplaires strictement identiques sont ignorés et la photo montre l’objet réellement possédé.
_Éviter_ : voiture, car, véhicule miniature

**Variante** :
Une représentation visuellement distincte d’un même personnage, par exemple Flash McQueen classique et Flash McQueen Dinoco.
_Éviter_ : doublon, exemplaire

**Fiche** :
La représentation numérique d’une Miniature Cars. Elle possède une photo, un nom français, une couleur principale et une description ; le numéro, l’équipe et les Œuvres sont facultatifs. Une Fiche suit le cycle Brouillon, Publiée, puis éventuellement Archivée. Une Fiche publiée apparaît dans le Garage ; une Fiche archivée en est retirée sans être définitivement effacée.
_Éviter_ : card, produit

**Œuvre** :
Un film, court-métrage ou épisode de série de l’univers *Cars* dans lequel apparaît une Miniature Cars. Le catalogue des Œuvres grandit uniquement selon les besoins des Fiches.
_Éviter_ : film, média, contenu

**Brouillon** :
Une Fiche, saisie manuellement ou proposée à partir de l’analyse d’une photo, qui n’apparaît pas encore dans le Garage. Elle peut être enregistrée avec sa seule photo. Sa publication exige une photo, un nom français, une couleur principale et une description validés par un Parent ; une information incertaine reste inconnue plutôt que d’être inventée.
_Éviter_ : résultat IA, publication automatique

**Enfant** :
L’utilisateur de quatre ans qui parcourt le Garage et écoute le nom et la description des Miniatures Cars, initialement avec l’aide d’un adulte.
_Éviter_ : client, compte enfant

**Mode Enfant** :
Le mode de consultation tactile et sonore du Garage. Il est strictement en lecture et constitue le mode affiché par défaut sur l’appareil familial.
_Éviter_ : mode visiteur, accès anonyme

**Session d’appareil** :
Un accès révocable, valable six mois et strictement limité au Mode Enfant, créé par un Parent pour une tablette ou un téléphone familial. Son activation remplace la session Parent sur cet appareil.
_Éviter_ : compte enfant, session Parent

**Parent** :
Un adulte invité, disposant de son propre accès Google au Garage et autorisé à ajouter, valider, corriger ou archiver des Fiches.
_Éviter_ : administrateur, contributeur

**Propriétaire** :
Le Parent responsable du Garage. Il peut en plus inviter ou retirer d’autres Parents, gérer les sauvegardes et restaurations, et supprimer définitivement une Fiche archivée. Le Garage possède initialement un seul Propriétaire.
_Éviter_ : super-administrateur, propriétaire du compte Supabase

**Appartenance au Garage** :
Le lien durable entre une personne et un Garage, avec son rôle de Propriétaire ou de Parent. Seule une appartenance active donne accès au Garage ; une appartenance retirée ou historique conserve la trace de ses actions sans rien autoriser. L’appartenance identifie les auteurs des Fiches sans révéler l’identité de la personne.
_Éviter_ : compte, utilisateur, membre

**Espace Parent** :
La zone protégée dans laquelle un Parent entretient le Garage et valide les Brouillons. Son ouverture nécessite une authentification adulte récente.
_Éviter_ : back-office, panneau d’administration

**Vitrine** :
Une collection de démonstration publique, distincte du Garage familial privé et de ses données réelles. Elle contient une sélection manuelle de Fiches et de photos explicitement approuvées, sans synchronisation avec le Garage.
_Éviter_ : Garage public, mode public

**Assistant ChatGPT** :
L’intégration facultative qui recherche les Fiches existantes et crée des Brouillons après confirmation d’un Parent. Elle ne peut ni publier, ni modifier, ni supprimer une Fiche.
_Éviter_ : administrateur IA, publication automatique

**Archive portable** :
Une sauvegarde versionnée du Garage contenant ses Fiches, ses Œuvres et ses photos, sans secret ni donnée d’authentification. Elle peut restaurer la collection indépendamment de son hébergeur.
_Éviter_ : export Supabase, sauvegarde de compte
