# Micro-API RPG

Ce projet implémente une API minimale pour requêter les données du Registre Parcellaire Graphique de l'ASP stockées dans une base locale postgresql/postgis.


## Installation et prérequis

Ce projet est écrit en python 3 qui doit donc être installé. Les modules utilisés peuvent être installés avec:

`pip3 install -r requirements.txt`

Une base postgresql avec postgis doit être aussi disponible pour le user courant. Elle n'est pas créé par ces scripts.


## Chargement des données

Téléchargement et import des données :

`./rpg_download_import.sh`


## Lancement du serveur

`gunicorn rpg_as_api:app -b 0.0.0.0:8888`


## Paramètres reconnus par l'API

Sélection par proximité géographique:
- distance de 100m: http://api.cquest.org/rpg?lat=47.86&lon=3.40&dist=1000
- distance par défaut de 500m: http://api.cquest.org/rpg?lat=47.86&lon=3.40
- distance de 100m et point en Lambert93: http://api.cquest.org/rpg?x=780000&y=6756000&dist=1000


Filtrage par:
- annee: http://api.cquest.org/rpg?lat=47.86&lon=3.40&dist=1000&annee=2016
- code_culture: http://api.cquest.org/rpg?lat=47.86&lon=3.40&dist=1000&code_culture=ORP

Le résultat est au format GeoJSON.

Voir aussi la définition OpenAPI dans rpg_as_api.yml
