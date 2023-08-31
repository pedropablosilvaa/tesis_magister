WITH risk_asses as (
    SELECT
        id,
        CASE
            WHEN risk_robust_scaled < -0.117 THEN 'Riesgo Bajo'
            WHEN (risk_robust_scaled >= -0.117 AND risk_robust_scaled < 0.1  ) THEN 'Riesgo Medio Bajo'
            WHEN (risk_robust_scaled >= 0.1 AND risk_robust_scaled < 0.154 ) THEN 'Riesgo Medio'
            WHEN (risk_robust_scaled >= 0.154  AND risk_robust_scaled < 1.301) THEN 'Riesgo Medio Alto'
            WHEN risk_robust_scaled >= 1.301 THEN 'Riesgo Alto'
        END as evaluacion_riesgo,
        ST_TRANSFORM(geom, 32718) as geom
    FROM 
        capas_estaticas."risk"
)

SELECT 
    evaluacion_riesgo,
    SUM(ST_area(geom))/1000000
FROM 
    risk_asses
GROUP BY
    evaluacion_riesgo


---------------------- kmeans -------------------------

WITH kmeans as (
    SELECT
        id,
        CASE
            WHEN cluster_4_cluster = '1' THEN 'Riesgo Bajo'
            WHEN cluster_4_cluster = '2' THEN 'Riesgo Medio Bajo'
            WHEN cluster_4_cluster = '3' THEN 'Riesgo Medio Alto'
            WHEN cluster_4_cluster = '0' THEN 'Riesgo Alto'
        END as evaluacion_riesgo,
        ST_TRANSFORM(geom, 32718) as geom
    FROM 
        capas_estaticas."risk_4"
)

SELECT 
    evaluacion_riesgo,
    SUM(ST_area(geom))/1000000
FROM 
    kmeans
GROUP BY
    evaluacion_riesgo


-----------------------------


WITH gmm as (
    SELECT
        CASE
            WHEN gmm_4_label = '5' THEN 'Riesgo Muy Bajo'
            WHEN gmm_4_label = '3' THEN 'Riesgo Bajo'
            WHEN gmm_4_label = '0' THEN 'Riesgo Medio Bajo'
            WHEN gmm_4_label = '2' THEN 'Riesgo Medio Alto'
            WHEN gmm_4_label = '4' THEN 'Riesgo Alto'
            WHEN gmm_4_label = '1' THEN 'Riesgo Muy Alto'
        END as evaluacion_riesgo,
        ST_TRANSFORM(geom, 32718) as geom
    FROM 
        capas_estaticas."risk_4_gmm"
)

SELECT 
    evaluacion_riesgo,
    SUM(ST_area(geom))/1000000
FROM 
    gmm
GROUP BY
    evaluacion_riesgo