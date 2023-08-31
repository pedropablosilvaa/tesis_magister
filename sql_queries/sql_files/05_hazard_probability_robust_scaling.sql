-- se elimina la tabla
DROP TABLE IF EXISTS capas_estaticas.probability_hazard_robust_scaling;

-- se crea la tabla
CREATE TABLE capas_estaticas.probability_hazard_robust_scaling as 

-- se cuentan las interesecciones
WITH entidades_18s as (
    SELECT
        id,
        hazard_prob,
        geom
    FROM 
        capas_estaticas.probability_hazard
),

stats as (
  SELECT
    percentile_cont(0.5) WITHIN GROUP (ORDER BY hazard_prob) AS median_hazard_prob,
    percentile_cont(0.25) WITHIN GROUP (ORDER BY hazard_prob) AS q1_hazard_prob,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY hazard_prob) AS q3_hazard_prob
  FROM entidades_18s
)


SELECT
    id, 
    hazard_prob,
    entidades_18s.hazard_prob - stats.median_hazard_prob AS hazard_prob_robust_scaled,
    geom
FROM
  entidades_18s, stats