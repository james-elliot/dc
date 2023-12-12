# DC
Construit une base de données mysql à partir des fichiers textes de décès de l'INSEE

Pour récupérer les fichiers textes de l'INSEE, utiliser le script

    ./retrieve.sh
qui les téléchargera tous.

Les fichiers INSEE doivent être nettoyés et mis en format CSV pour être ingérés directement par mysql.
Le programme *deces.ml* les traitera et les concatènera dans un fichier csv.
Pour le compiler:

    make
Une fois compilé, la syntaxe pour concaténer tous les fichiers de 1970 à 2022 est:

    ./deces 1970 2022
Le fichier résultat s'appellera *deces-1970-2022.csv*.

Le fichier *deces.sql* contient les commandes sql de base pour créer la base de données mysql à partir du fichier csv.

Le fichier *deces_postgres.sql* contient les mêmes commandes pour Postgre.

Les dates ont volontairement été placés dans trois champs différents (jour, mois, année) car certaines dates sont incorrectes (informations manquantes, ou dates impossibles). Les stocker dans un seul champ date aurait imposé un pré-processing qui aurait possiblement détruit des informations.

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


Le fichier est fourni au format txt, l'encodage est en ASCII sauf pour quelques caractères parasites en UTF-8. Comme l'indexage indiqué ci-dessous est fait sur les caractères et non sur les octets, il est indispensable de prétraiter toutes les lignes, ou d'utiliser une librairie capable de prendre en compte le codage UTF-8 des chaines de caractères (utilisation par exemple d'un itérateur *s.chars()* sur les caractères en Rust).

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
