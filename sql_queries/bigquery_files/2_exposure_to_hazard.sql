/*
Esta query tiene 

*/


-- se elimina la capa de ruteo
DROP TABLE IF EXISTS `tesispregrado.tesis_magister.exposure_to_hazard`;

-- se crea la capa de ruteo
CREATE TABLE `tesispregrado.tesis_magister.exposure_to_hazard` as 

WITH entidades_1 as (
      SELECT
        id,
        geom
    FROM 
       `tesispregrado.tesis_magister.exposure_to_hazard_01`
),

entidades_18s as (
    SELECT
        id,
        geom_text as geom
    FROM 
       `tesispregrado.tesis_magister.social_vulnerability`
    WHERE id NOT IN (select id
    FROM entidades_1)
    
    
),

hazard as (
    SELECT
        ST_GEOGFROMTEXT(geom_text) as geom
    FROM 
        `tesispregrado.tesis_magister.area_cierre`
),

ccaa_estado as (
    SELECT
        id,
        SAFE.ST_GEOGFROMTEXT(geom_text) as geom          
    FROM
      `tesispregrado.tesis_magister.ccaa_estado`
),

calculate_dist_hazard as (
    SELECT
        entidad.id,
        entidad.geom,
        ST_DISTANCE(SAFE.ST_GEOGFROMTEXT(entidad.geom), hazard.geom) AS dist_hazard
    FROM 
        entidades_18s as entidad, hazard
),

-- obtener la cantidad de ccaa a 5000 metros de cada entidades
count_ccaa_by_entidad as (
    SELECT
        entidad.id,
        entidad.geom AS geom_str,
        COUNT(ccaa.geom) AS count_closes_ccaa
    FROM 
        entidades_18s as entidad
    LEFT JOIN 
        ccaa_estado as ccaa
    ON 
        ST_DWithin(SAFE.ST_GEOGFROMTEXT(entidad.geom),  ccaa.geom, 5000)
    GROUP BY
        entidad.id, geom_str
),

handle_nulls_values as (
    SELECT
        id,
        geom_str as geom,
        CASE 
            WHEN count_closes_ccaa IS NULL THEN 0
        ELSE count_closes_ccaa
        END AS count_closes_ccaa
    FROM
        count_ccaa_by_entidad
)

SELECT
    id,
    dist_hazard,
    CASE 
        WHEN dist_hazard  < 20000 THEN 0.569
        WHEN (dist_hazard  >= 20000 AND dist_hazard < 30000) THEN 0.253
        WHEN (dist_hazard  >= 30000 AND dist_hazard < 50000) THEN 0.129
        WHEN (dist_hazard  >= 50000) THEN 0.055
    END AS dist_hazard_weighted,
    count_closes_ccaa as near_ccaa,
    CASE 
        WHEN count_closes_ccaa  = 0 THEN 0.055
        WHEN (count_closes_ccaa  > 0 AND count_closes_ccaa < 20) THEN 0.129
        WHEN (count_closes_ccaa  >= 20 AND count_closes_ccaa < 40) THEN 0.253
        WHEN (count_closes_ccaa  >= 40) THEN 0.569
    END AS near_ccaa_weighted,
    calculate_dist_hazard.geom as geom
FROM calculate_dist_hazard 
LEFT JOIN 
    handle_nulls_values as ccaa
	USING(id)
UNION ALL 
SELECT * 
FROM `tesispregrado.tesis_magister.exposure_to_hazard_01` 
