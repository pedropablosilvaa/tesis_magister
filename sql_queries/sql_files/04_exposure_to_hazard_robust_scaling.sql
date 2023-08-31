/*
Esta query tiene 

*/


-- se elimina la capa de ruteo
DROP TABLE IF EXISTS capas_estaticas.exposure_to_hazard_robust_scaling;

-- se crea la capa de ruteo
CREATE TABLE capas_estaticas.exposure_to_hazard_robust_scaling as 

WITH entidades_18s as (
    SELECT
        id,
        dist_hazard,
        near_ccaa,
        geom
    FROM 
        capas_estaticas.exposure_to_hazard
),


stats as (
  SELECT
    percentile_cont(0.5) WITHIN GROUP (ORDER BY dist_hazard) AS median_dist_hazard,
    percentile_cont(0.25) WITHIN GROUP (ORDER BY dist_hazard) AS q1_dist_hazard,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY dist_hazard) AS q3_dist_hazard,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY near_ccaa) AS median_near_ccaa,
    percentile_cont(0.25) WITHIN GROUP (ORDER BY near_ccaa) AS q1_near_ccaa,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY near_ccaa) AS q3_near_ccaa
  FROM entidades_18s
)

SELECT
    id, 
    dist_hazard,
    near_ccaa,
    (entidades_18s.near_ccaa - stats.median_near_ccaa) / (stats.q3_near_ccaa - stats.q1_near_ccaa) AS near_ccaa_robust_scaled,
    (entidades_18s.dist_hazard - stats.median_dist_hazard) / (stats.q3_dist_hazard - stats.q1_dist_hazard) AS dist_hazard_robust_scaled,
    geom
FROM
  entidades_18s, stats
