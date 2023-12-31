# DC
Construit une base de données mysql à partir des fichiers textes de décès de l'INSEE

Pour récupérer les fichiers textes de l'INSEE de 1970 à 2022, utiliser le script

    ./retrieve.sh
qui les téléchargera tous.

Les fichiers INSEE doivent être nettoyés et mis en format CSV pour être ingérés directement par mysql.
Le programme *deces.c* ou le programme *deces.ml* les traitera et les concatènera dans un fichier csv.
Pour compiler le programme C:

    make deces_c
Pour compiler le programme ML:

	make deces_ml
Une fois compilé, la syntaxe pour concaténer tous les fichiers de 1970 à 2022 est:

    ./deces_c 1970 2022
Le fichier résultat s'appellera *deces-1970-2022.csv*. Pour information, il faut environ 20s au programme C pour traiter la totalité des fichiers de 1970 à 2022, et 80s au programme ML. La différence d'efficacité n'est pas lié au langage, mais à la façon de les utiliser. Le programme ML a été écrit en très peu de temps, et sans erreur ni debugging, le programme en C ne fait jamais de copie et modifie les chaines "en place", mais a nécessité un peu plus de temps d'écriture, et je ne recommanderais pas ce type de programmation à des débutants.

Il existe également une version en ZIG du programme, qui fonctionne comme la version en C et en ML. Elle est légèrement plus rapide que le C (10% environ). Pour la compiler:

	make deces

Le fichier *deces.sql* contient les commandes sql de base pour créer la base de données mysql à partir du fichier csv.

Le fichier *deces_postgres.sql* contient les mêmes commandes pour Postgre.

Les dates ont volontairement été placés dans trois champs différents (jour, mois, année) car certaines dates sont incorrectes (informations manquantes, ou dates impossibles). Les stocker dans un seul champ date aurait imposé un pré-processing qui aurait possiblement détruit des informations.

Les fichiers INSEE sont fournis au format txt, mais ils sont de mauvaise qualité. L'encodage est en ASCII sauf pour quelques caractères en UTF-8 dont la majorité sont des REPLACEMENT_CHAR U+FFFD, probablement liés à des erreurs de décodage. D'autre part, il existe également des octets avec une valeur supérieure à 0x7F, mais qui ne sont pas des préfixes à un encodage UTF-8 valide. Il est également nécessaire de supprimer un certain nombre de caractères cachés, dont des NUL, des DEL, etc... Le choix a donc été fait  de transformer la totalité du fichier CSV en ASCII de base, et en majuscules. Comme l'indexage indiqué ci-dessous est fait sur les caractères et non sur les octets, il est indispensable de prétraiter toutes les lignes.  

IL y a également une version Rust du programme *deces.rs*. Pour la compiler

	make deces_rs
	
La version Rust fonctionne différemment des versions C, ML et ZIG. Elle conserve les caractères UTF-8 sauf les REPLACEMENT_CHAR (à noter que cela conserve certains caractères accentués, mais conserve également des caractères sans signification). Les caractères non valides sont interprétés comme de l'ISO-8859-1 et convertis en UTF-8, les codes compris entre 0x7F et 0xBF sont supprimés à l'exception de 0xB0, 0xBA, OXAB et OxBB. Toutes les chaines de caractères sont transformées en capitales.

<h2>Organisation des fichiers INSEE</h2>

Chaque enregistrement est relatif à une personne décédée et comporte les zones suivantes :

    le nom de famille
    les prénoms
    le sexe
    la date de naissance
    le code du lieu de naissance
    la localité de naissance en clair (pour les personnes nées en France ou dans les DOM/TOM/COM)
    le libellé de pays de naissance en clair (pour les personnes nées à l'étranger)
    la date du décès
    le code du lieu de décès
    le numéro d'acte de décès


Nom et Prénom - Longueur : 80 - Position : 1-80 - Type : Alphanumérique
La forme générale est NOM*PRENOMS

Sexe - Longueur : 1 - Position : 81 - Type : Numérique
1 = Masculin; 2 = féminin

Date de naissance - Longueur : 8 - Position : 82-89 - Type : Numérique
Forme : AAAAMMJJ - AAAA=0000 si année inconnue; MM=00 si mois inconnu; JJ=00 si jour inconnu

Code du lieu de naissance - Longueur : 5 - Position : 90-94 - Type : Alphanumérique
Code Officiel Géographique en vigueur au moment de la prise en compte du décès

Commune de naissance en clair - Longueur : 30 - Position : 95-124 - Type : Alphanumérique

DOM/TOM/COM/Pays de naissance en clair - Longueur : 30 - Position : 125-154 - Type : Alphanumérique

Date de décès - Longueur : 8 - Position : 155-162 - Type : Numérique
Forme : AAAAMMJJ - AAAA=0000 si année inconnue; MM=00 si mois inconnu; JJ=00 si jour inconnu

Code du lieu de décès - Longueur : 5 - Position : 163-167 - Type : Alphanumérique
Code Officiel Géographique en vigueur au moment de la prise en compte du décès

Numéro d'acte de décès - Longueur : 9 - Position : 168-176 - Type : Alphanumérique
NOTA : Certains enregistrements peuvent contenir en toute fin des caractères non significatifs. Il est donc important, pour lire correctement ce champ, de bien respecter sa longueur ou sa borne de fin.
