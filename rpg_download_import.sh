#! /bin/bash

# Script de téléchargement et chargement des données RPG dans postgresql

for CMD in wget unzip ogr2ogr psql
do
  if [ "$(which $CMD)" = "" ]
  then
    echo "$CMD non installé"
    echo "sudo apt install wget unzip gdal-bin postgresql"
    exit
  fi
done

mkdir -p data
cd data

# 2017
wget -N -c http://data.cquest.org/registre_parcellaire_graphique/2017/RPG_2-0_SHP_LAMB93_FR-2017-PARCELLES.zip
unzip -jn RPG_2-0_SHP_LAMB93_FR-2017-PARCELLES.zip

# import postgresql avec reprojection WGS84
ogr2ogr -f postgresql PG:dbname=$USER -nln rpg_2017_parcelles -nlt geometry -t_srs EPSG:4326 PARCELLES_GRAPHIQUES.shp
psql -c "
alter table rpg_2017_parcelles drop ogc_fid;
create or replace view rpg_parcelles as
  select 2017 as annee, id_parcel as id_parcelle, code_cultu as code_culture, code_group as code_groupe, culture_d1, culture_d2, wkb_geometry rpg_2017_parcelles;
"
# nettoyage
rm -f PARCELLES*

# 2016
wget -N -c http://data.cquest.org/registre_parcellaire_graphique/rpg2016-wgs84-plus.zip
unzip -jn rpg2016-wgs84-plus.zip
ogr2ogr -f postgresql PG:dbname=$USER -nln rpg_2016_parcelles -nlt geometry rpg2016.shp
rm -f rpg2016.*
psql -c "
alter table rpg_2016_parcelles drop ogc_fid;
create or replace view rpg_parcelles as
  select 2017 as annee, id_parcel as id_parcelle, code_cultu as code_culture, code_group as code_groupe, culture_d1, culture_d2, wkb_geometry rpg_2017_parcelles
union
  select 2016 as annee, id_parcel as id_parcelle, code_cultu as code_culture, code_group as code_groupe, culture_d1, culture_d2, wkb_geometry from rpg_2016_parcelles;
"

# nettoyage
rm -f rpg2016.*

# 2015
wget -N -c http://data.cquest.org/registre_parcellaire_graphique/2015/RPG_2-0_SHP_LAMB93_FR-2015-PARCELLES.zip
unzip -jn RPG_2-0_SHP_LAMB93_FR-2015-PARCELLES.zip
ogr2ogr -f postgresql PG:dbname=$USER -nln rpg_2015_parcelles -nlt geometry -t_srs EPSG:4326 PARCELLES_GRAPHIQUES.shp

psql -c "
alter table rpg_2015_parcelles drop ogc_fid;
create or replace view rpg_parcelles as
  select 2017 as annee, id_parcel as id_parcelle, code_cultu as code_culture, code_group as code_groupe, culture_d1, culture_d2, wkb_geometry from rpg_2017_parcelles
union
  select 2016 as annee, id_parcel as id_parcelle, code_cultu as code_culture, code_group as code_groupe, culture_d1, culture_d2, wkb_geometry from rpg_2016_parcelles
union
  select 2015 as annee, id_parcel as id_parcelle, code_cultu as code_culture, code_group as code_groupe, culture_d1, culture_d2, wkb_geometry from rpg_2015_parcelles;
"

# nettoyage
rm -f PARCELLES*
