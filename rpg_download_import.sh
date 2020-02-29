#! /bin/bash

# Script de téléchargement et chargement des données RPG dans postgresql

# par défaut on utilise la base PG du user courant
DB=$USER

for CMD in wget unzip ogr2ogr psql 7z
do
  if [ "$(which $CMD)" = "" ]
  then
    echo "$CMD non installé"
    echo "sudo apt install wget unzip gdal-bin postgresql p7zip-full"
    exit
  fi
done

mkdir -p data
cd data

# 2015
wget -N -c http://data.cquest.org/registre_parcellaire_graphique/2015/RPG_2-0_SHP_LAMB93_FR-2015-PARCELLES.zip
unzip -jn RPG_2-0_SHP_LAMB93_FR-2015-PARCELLES.zip
ogr2ogr -f pgdump /vsistdout/ --config PG_USE_COPY YES -nln rpg_2015_parcelles -nlt geometry -t_srs EPSG:4326 PARCELLES_GRAPHIQUES.shp | psql $DB
# nettoyage
rm -f PARCELLES*

# 2016
wget -N -c http://data.cquest.org/registre_parcellaire_graphique/rpg2016-wgs84-plus.zip
unzip -jn rpg2016-wgs84-plus.zip
ogr2ogr -f pgdump /vsistdout/ --config PG_USE_COPY YES -nln rpg_2016_parcelles -nlt geometry rpg2016.shp | psql $DB
rm -f rpg2016.*

# 2017
wget -N -c http://data.cquest.org/registre_parcellaire_graphique/2017/RPG_2-0_SHP_LAMB93_FR-2017-PARCELLES.zip
unzip -jn RPG_2-0_SHP_LAMB93_FR-2017-PARCELLES.zip
# import postgresql avec reprojection WGS84
ogr2ogr -f pgdump /vsistdout/ --config PG_USE_COPY YES -nln rpg_2017_parcelles -nlt geometry -t_srs EPSG:4326 PARCELLES_GRAPHIQUES.shp | psql $DB
# nettoyage
rm -f PARCELLES*


# 2018
wget -N -nv http://data.cquest.org/registre_parcellaire_graphique/2018/RPG_2-0__SHP_LAMB93_FR-2018_2018-01-15.7z
7z x RPG_2-0__SHP_LAMB93_FR-2018_2018-01-15.7z
# import postgresql avec reprojection WGS84
ogr2ogr -f pgdump /vsistdout/ --config PG_USE_COPY YES -nln rpg_2018_parcelles -nlt geometry -t_srs EPSG:4326 RPG*2018*/*/*/*/PARCELLES_GRAPHIQUES.shp | psql $DB
# nettoyage
rm -rf RPG*2018*


# création/mise à jour de la vue couvrant les différents millésimes
psql $DB -c "
create or replace view rpg_parcelles as
  SELECT 2018 as annee, id_parcel as id_parcelle, code_cultu as code_culture, code_group as code_groupe, culture_d1, culture_d2, wkb_geometry FROM rpg_2018_parcelles
union
  select 2017 as annee, id_parcel as id_parcelle, code_cultu as code_culture, code_group as code_groupe, culture_d1, culture_d2, wkb_geometry FROM rpg_2017_parcelles
union
  select 2016 as annee, id_parcel as id_parcelle, code_cultu as code_culture, code_group as code_groupe, culture_d1, culture_d2, wkb_geometry from rpg_2016_parcelles
union
  select 2015 as annee, id_parcel as id_parcelle, code_cultu as code_culture, code_group as code_groupe, culture_d1, culture_d2, wkb_geometry from rpg_2015_parcelles;
"
