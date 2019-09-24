#! /usr/bin/python3

# modules additionnels
import falcon
import psycopg2

SOURCE = 'ASP / Registre Parcellaire Graphique'
DERNIER_MILLESIME = '2017'
LICENCE = 'Licence Ouverte'

class rpg(object):
    def getRPG(self, req, resp):
        db = psycopg2.connect("")  # connexion à la base PG locale
        cur = db.cursor()

        where = ''
        where2 = b''

        annee = req.params.get('annee', None)
        if annee:
            where2 = cur.mogrify(' AND annee = %s ', (annee,))

        code_culture = req.params.get('code_culture', None)
        if code_culture and len(code_culture) == 3:
            where2 = where2 + \
                cur.mogrify(' AND code_culture = %s ', (code_culture,))

        lat,lon = (req.params.get('lat', None), req.params.get('lon', None))
        dist = min(int(req.params.get('dist',100)),1000)
        epsg = 4326

        x,y = (req.params.get('x', None), req.params.get('y', None))
        if x and y:
            # on a des coordonnées en lambert...
            lat,lon = (y, x)
            epsg = 2154

        if lat and lon:  # recherche géographique
            query = cur.mogrify("""
select json_build_object('source', %s,
    'derniere_maj', %s,
    'licence', %s,
    'type','Featurecollection',
    'features', case when count(*)=0 then array[]::json[] else array_agg(json_build_object('type','Feature',
                                            'properties',json_strip_nulls(row_to_json(p))::jsonb - 'wkb_geometry'
                                                || json_build_object('bbox', st_asgeojson(st_transform(st_envelope(wkb_geometry),%s),6,0)::json)::jsonb
                                                || json_build_object('centroid', st_asgeojson(st_transform(st_centroid(wkb_geometry),%s),6,0)::json)::jsonb
                                            ,
                                            'geometry',st_asgeojson(st_transform(wkb_geometry,%s),6,0)::json)) end )::text
from rpg_parcelles p 
where st_buffer(st_transform(st_setsrid(st_makepoint(%s, %s),%s),4326)::geography, %s)::geometry && wkb_geometry
    and ST_DWithin(st_transform(st_setsrid(st_makepoint(%s, %s),%s),4326)::geography, wkb_geometry::geography, %s)
""", (SOURCE, DERNIER_MILLESIME, LICENCE, epsg, epsg, epsg, lon, lat, epsg, dist, lon, lat, epsg, dist)) + where2

            cur.execute(query)
            dvf = cur.fetchone()

            resp.status = falcon.HTTP_200
            resp.set_header('X-Powered-By', 'rpg_as_api')
            resp.set_header('Access-Control-Allow-Origin', '*')
            resp.set_header("Access-Control-Expose-Headers","Access-Control-Allow-Origin")
            resp.set_header('Access-Control-Allow-Headers','Origin, X-Requested-With, Content-Type, Accept')
            resp.set_header('X-Robots-Tag', 'noindex, nofollow')
            resp.body = dvf[0]
        else:
            resp.status = falcon.HTTP_413
            resp.body = '{"erreur": "aucun critère de recherche indiqué"}'

        db.close()

    def on_get(self, req, resp):
        self.getRPG(req, resp)

# instance WSGI et route vers notre API
app = falcon.API()
app.add_route('/rpg', rpg())
