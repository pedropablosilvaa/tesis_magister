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

-- Calcular el valor mínimo y máximo de la columna dist_hazard
min_max_entidad AS (
    SELECT
        MIN(dist_hazard) AS min_hazard,
        MAX(dist_hazard) AS max_hazard
    FROM 
		calculate_dist_hazard
)

SELECT
    id,
    dist_hazard,
    (entidad.dist_hazard - min_hazard) / (max_hazard - min_hazard) as hazard_norm,
    entidad.geom
FROM calculate_dist_hazard as entidad, min_max_entidad as min_max 

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