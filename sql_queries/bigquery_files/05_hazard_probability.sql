/*
select 
 id_0,
st_astext(st_transform(geom, 4326)) as geom_text
from capas_estaticas."cierres_concat" 


*/


-- se elimina la tabla
DROP TABLE IF EXISTS `tesispregrado.tesis_magister.probability_hazard`;

-- se crea la tabla
CREATE TABLE `tesispregrado.tesis_magister.probability_hazard` as 

-- se cuentan las interesecciones
WITH entidades_18s as (
    SELECT
        id,
        geom_text as geom
    FROM 
        `tesispregrado.tesis_magister.social_vulnerability`
),

-- obtener numero de veces que un ccaa se vio afectada por un cierre
count_entidad_affected_by_close as (
    SELECT
        entidad.id,
        entidad.geom AS geom,
        COUNT(cierres.geom_text) AS count_closed_entidad
    FROM 
        entidades_18s as entidad
    LEFT JOIN 
        `tesispregrado.tesis_magister.cierres_simp` AS cierres
    ON 
        ST_DWithin(SAFE.ST_GEOGFROMTEXT(entidad.geom),  st_geogfromtext(cierres.geom_text, make_valid => TRUE), 10000)
    GROUP BY
        entidad.id, entidad.geom
),

count_cierres as (
    SELECT 
        COUNT(geom_text) as cierres_totales
    FROM 
        `tesispregrado.tesis_magister.cierres_concat`
),

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
    CASE 
        WHEN count_closed_entidad  = 0 THEN 0.048
        WHEN (count_closed_entidad  > 0 AND count_closed_entidad < 20) THEN 0.102
        WHEN (count_closed_entidad  >= 20 AND count_closed_entidad < 40) THEN 0.266
        WHEN (count_closed_entidad  >= 40) THEN 0.583
    END AS count_closes_weighted,
    cierres.hazard_prob,
    CASE 
        WHEN hazard_prob  = 0 THEN 0.048
        WHEN (hazard_prob  > 0 AND hazard_prob < 0.20) THEN 0.102
        WHEN (hazard_prob  >= 0.2 AND hazard_prob < 0.4) THEN 0.266
        WHEN (hazard_prob  >= 0.4) THEN 0.583
    END AS hazard_prob_weighted,
    cierres.geom
FROM
    calculate_hazard_probability as cierres