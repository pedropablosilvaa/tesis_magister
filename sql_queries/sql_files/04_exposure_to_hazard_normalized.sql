/*
Esta query tiene 

*/


-- se elimina la capa de ruteo
DROP TABLE IF EXISTS capas_estaticas.exposure_to_hazard_normalized;

-- se crea la capa de ruteo
CREATE TABLE capas_estaticas.exposure_to_hazard_normalized as 

WITH entidades_18s as (
    SELECT
        id,
        dist_hazard,
        geom
    FROM 
        capas_estaticas.exposure_to_hazard
),

-- Calcular el valor mínimo y máximo de la columna dist_hazard
min_max_entidad AS (
    SELECT
        MIN(dist_hazard) AS min_hazard,
        MAX(dist_hazard) AS max_hazard
    FROM 
		entidades_18s
)

SELECT
    id,
    dist_hazard,
    (entidad.dist_hazard - min_hazard) / (max_hazard - min_hazard) as hazard_norm,
    entidad.geom
FROM entidades_18s as entidad, min_max_entidad as min_max 
