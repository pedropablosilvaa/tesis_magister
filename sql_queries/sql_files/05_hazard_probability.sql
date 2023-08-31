-- se elimina la tabla
DROP TABLE IF EXISTS capas_estaticas.probability_hazard;

-- se crea la tabla
CREATE TABLE capas_estaticas.probability_hazard as 

-- se cuentan las interesecciones
WITH entidades_18s as (
    SELECT
        id,
        entidad_geom as geom
    FROM 
        capas_estaticas."economic_vulnerability"
),

-- obtener numero de veces que un ccaa se vio afectada por un cierre
count_entidad_affected_by_close as (
    SELECT
        entidad.id,
        entidad.geom AS geom,
        COUNT(cierres.geom) AS count_closed_entidad
    FROM 
        entidades_18s as entidad
    LEFT JOIN 
        capas_estaticas.cierres_concat AS cierres
    ON 
        ST_DWithin(entidad.geom,  cierres.geom, 5000)
    GROUP BY
        entidad.id, entidad.geom
),

count_cierres as (
    SELECT 
        COUNT(*) as cierres_totales
    FROM 
        capas_estaticas.cierres_concat
)

-- se calcula la probabilidad de amenaza como la cantida de veces que 
-- se ha cerrado un ccaa dividido por la cantidad de cierres totales.
calculate_hazard_probability AS (
    SELECT 
        id, 
        count_closed_entidad,
        count_closed_entidad/(SELECT cierres_totales FROM count_cierres) as hazard_prob,
        geom
    FROM
        count_entidad_affected_by_close
)

SELECT
    cierres.id,
    cierres.count_closed_entidad as count_closes,
    cierres.hazard_prob,
    CASE 
        WHEN hazard_prob  < 20 THEN 0.613
        WHEN (hazard_prob  >= 30 AND hazard_prob < 50) THEN 0.089
        WHEN (hazard_prob  >= 20 AND hazard_prob < 30) THEN 0.225
        WHEN (hazard_prob  >= 50) THEN 0.043
    END AS hazard_prob_weighted,
    cierres.geom
FROM
    calculate_hazard_probability as cierres