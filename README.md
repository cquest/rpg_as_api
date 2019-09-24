# Micro-API RPG

Ce projet implémente une API minimale pour requêter les données du Registre Parcellaire Graphique de l'ASP stockées dans une base locale postgresql.

## Installation

Ce projet est écrit en python 3 qui doit donc être installé. Les modules utilisés peuvent être installés avec:

`pip3 install -r requirements.txt`


## Chargement des données

Téléchargement et import des données :

`./rpg_download_import.sh`

## Lancement du serveur

`gunicorn dvf_as_api:app -b 0.0.0.0:8888`

## Paramètres reconnus par l'API

Sélection par proximité géographique:
- distance de 100m: http://localhost:8888/rpg?lat=48.85&lon=2.35&dist=100
- distance par défaut de 500m: http://localhost:8888/rpg?lat=48.85&lon=2.35

Filtrage par:
- annee: http://localhost:8888/dvf?lat=48.85&lon=2.35&dist=100&annee=2016
- code_culture: http://localhost:8888/dvf?lat=48.85&lon=2.35&dist=100&code_culture=ORP

Le résultat est au format GeoJSON.

Voir aussi la définition OpenAPI dans rpg_as_api.yml
