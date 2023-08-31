/*
Esta query tiene 

*/


-- se elimina la capa de ruteo
DROP TABLE IF EXISTS capas_estaticas.exposure_to_hazard;

-- se crea la capa de ruteo
CREATE TABLE capas_estaticas.exposure_to_hazard as 

WITH entidades_18s as (
    SELECT
        id,
        ST_Transform(geom, 32718) AS geom
    FROM 
        capas_estaticas."social_vulnerability"
),

hazard as (
    SELECT
        ST_Transform(geom, 32718) AS geom
    FROM 
        capas_estaticas."area_cierre"
),

calculate_dist_hazard as (
    SELECT
        entidad.id,
        entidad.geom,
        ST_DISTANCE(entidad.geom, hazard.geom) AS dist_hazard
    FROM 
        entidades_18s as entidad, hazard
),
--><

-- obtener la cantidad de ccaa a 5000 metros de cada entidades
count_ccaa_by_entidad as (
    SELECT
        entidad.id,
        entidad.geom AS geom,
        COUNT(ccaa.geom) AS count_closes_ccaa
    FROM 
        entidades_18s as entidad
    LEFT JOIN 
        capas_estaticas."CCAA_estado" as ccaa
    ON 
        ST_DWithin(entidad.geom,  ST_Transform(ccaa.geom, 32718), 5000)
    WHERE ccaa.REP_SUBPESCA2.ADM_UOT.PULLINQUE4_T_ACUICULTURA.T_ESTADOTRAMITE = 'CONCESION OTORGADA'
    GROUP BY
        entidad.id, entidad.geom
),

handle_nulls_values as (
    SELECT
        id,
        geom,
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
        WHEN dist_hazard  < 20 THEN 0.613
        WHEN (dist_hazard  >= 20 AND dist_hazard < 30) THEN 0.225
        WHEN (dist_hazard  >= 30 AND dist_hazard < 50) THEN 0.089
        WHEN (dist_hazard  >= 50) THEN 0.043
    END AS dist_hazard_weighted,
    count_closes_ccaa as near_ccaa,
    CASE 
        WHEN count_closes_ccaa  < 20 THEN 0.613
        WHEN (count_closes_ccaa  >= 30 AND count_closes_ccaa < 50) THEN 0.089
        WHEN (count_closes_ccaa  >= 20 AND count_closes_ccaa < 30) THEN 0.225
        WHEN (count_closes_ccaa  >= 50) THEN 0.043
    END AS near_ccaa_weighted,
    calculate_dist_hazard.geom
FROM calculate_dist_hazard 
LEFT JOIN 
    handle_nulls_values as ccaa
	USING(id)
/*
SELECT
    id,
    geom,
    CASE 
        WHEN dist_hazard < 5000 THEN 1
        WHEN dist_hazard BETWEEN 5000 AND 10000 THEN 0.6
        WHEN dist_hazard  10000 > THEN 0
    
FROM 
    calculate_dist_hazard


*/