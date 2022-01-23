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
WITH select_ccaa as (
	SELECT DISTINCT
		a.*
		FROM capas_estaticas."CCAA" AS a,
		capas_estaticas.cierre_salud AS c
		WHERE ST_WITHIN(a.geom, c.geom) = TRUE
),
filter_by_region as (
	SELECT DISTINCT 
		a.*
		FROM capas_estaticas."business_location" AS a,
		capas_estaticas.region_x AS c
		WHERE ST_DWithin(a.geom, c.geom, 1000) = TRUE
),

markets_affected as (
	SELECT DISTINCT
		a.*
		FROM filter_by_region AS a,
		select_ccaa AS c
		WHERE ST_DWithin(a.geom, c.geom, 5000) = TRUE
)

select * from markets_affected



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