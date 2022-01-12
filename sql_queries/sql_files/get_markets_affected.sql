CREATE OR REPLACE table_name

WITH select_ccaa AS (
    SELECT
    a.*,
    ST_WITHIN(a.geom, c.geom) AS intersect
    FROM {{ccaa_layer}} AS a,
    {{closed_area_layer}} AS c
    WHERE intersect = TRUE
),
buffer_ccaa AS (
    SELECT ST_BUFFER(geom, {{buffer_dist}})
    FROM select_ccaa
)

SELECT a.*,
    ST_WITHIN(a.geom, c.geom) AS is_affected
    FROM {{markets_layer}} AS a,
    buffer_ccaa AS c
    WHERE is_affected = TRUE




'''
                           SELECT a.*, 
                           ST_WITHIN(a.geom, c.geom) as intersect
                           FROM {{ccaa_layer}} as a,
                           {{closed_area_layer}} as c 
                           WHERE intersect = TRUE
                        ),

                        buffer_ccaa as (
                           SELECT ST_BUFFER(geom, {{buffer_dist}})
                           FROM select_ccaa
                        )

                        SELECT a.*,
                        ST_WITHIN(a.geom, c.geom) as is_affected
                        FROM {{markets_layer}} as a,
                        buffer_ccaa as c
                        WHERE is_affected = TRUE
                        ),



--------------------
------- Ahora modo prueba en qgis y tambien en postgis

WITH select_ccaa as (
	SELECT
		a.*,
		ST_WITHIN(a.geom, c.geom) AS intersect
		FROM capas_estaticas."CCAA" AS a,
		capas_estaticas.cierre_salud AS c
		WHERE ST_WITHIN(a.geom, c.geom) = TRUE
)
	SELECT
		ST_BUFFER(geom, 300)
		FROM select_ccaa
    

)


'''