/*
Esta query tiene como objetivo obtener una tabla final 
con las geometrías, los nombres, y el valor de vulnerabilidad
espacial [0,1]  

*/


-- se elimina la capa de ruteo
DROP TABLE IF EXISTS capas_estaticas."response_capacity_robust_scaling";

-- se crea la capa de ruteo
CREATE TABLE capas_estaticas."response_capacity_robust_scaling" as 

WITH entidades_18s as (
    SELECT
        id,
        conteo_sii_total,
        conteo_sii_acuicultura,
        prop_respuesta,
		entidad_geom
    FROM 
        capas_estaticas.response_capacity
),

stats as (
  SELECT
    percentile_cont(0.5) WITHIN GROUP (ORDER BY prop_respuesta) AS median_prop_respuesta,
    percentile_cont(0.25) WITHIN GROUP (ORDER BY prop_respuesta) AS q1_prop_respuesta,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY prop_respuesta) AS q3_prop_respuesta
  FROM entidades_18s
)

SELECT
    id,
	conteo_sii_total,
	conteo_sii_acuicultura,
    prop_respuesta,
    (entidades_18s.prop_respuesta - stats.median_prop_respuesta) / (stats.q3_prop_respuesta - stats.q1_prop_respuesta) AS prop_respuesta_robust_scaled,
    entidad_geom
FROM
  entidades_18s, stats
