-- se elimina la capa de ruteo
DROP TABLE IF EXISTS capas_estaticas.risk;

-- se crea la capa de ruteo
CREATE TABLE capas_estaticas.risk as 

WITH consolidated_table as (
    SELECT
        social_vulnerability.id,
        social_vulnerability.personas_weighted,
        social_vulnerability.pobl_depend_weighted,
        economic_vulnerability.conteo_sii_weighted,
        economic_vulnerability.conteo_plantas_weighted,
        response_capacity.prop_respuesta_weighted,
        response_capacity.prop_respuesta,
        expose_hazard.dist_hazard_weighted,
        expose_hazard.near_ccaa_weighted,
        hazard_prob.count_closes_weighted,
        hazard_prob.hazard_prob_weighted,
        hazard_prob.hazard_prob,
        social_vulnerability.geom
    FROM
       capas_estaticas."social_vulnerability" as social_vulnerability
    LEFT JOIN
       capas_estaticas."economic_vulnerability" as economic_vulnerability
    ON social_vulnerability.id = economic_vulnerability.id
    LEFT JOIN
        capas_estaticas."response_capacity" AS response_capacity
    ON social_vulnerability.id = response_capacity.id
    LEFT JOIN
        capas_estaticas."exposure_to_hazard" as expose_hazard
    ON social_vulnerability.id = expose_hazard.id
    LEFT JOIN
        capas_estaticas."probability_hazard" as hazard_prob
    ON social_vulnerability.id = hazard_prob.id
),

calculate_vulnerability as (
    SELECT
        id,
        SUM(personas_weighted*0.614 
            + pobl_depend_weighted*0.251 
            + conteo_sii_weighted*0.068 
            + conteo_plantas_weighted*0.068) as vulnerability,
        SUM(dist_hazard_weighted*0.5
            + near_ccaa_weighted*0.5) as exposure_hazard,
        personas_weighted,
        pobl_depend_weighted,
        conteo_sii_weighted,
        conteo_plantas_weighted,
        prop_respuesta_weighted,
        dist_hazard_weighted,
        near_ccaa_weighted,
        hazard_prob_weighted,
        prop_respuesta,
        hazard_prob,
        geom
    FROM
        consolidated_table
    group by id, personas_weighted, pobl_depend_weighted, conteo_sii_weighted, conteo_plantas_weighted, prop_respuesta_weighted, dist_hazard_weighted,near_ccaa_weighted,hazard_prob_weighted,prop_respuesta,
            hazard_prob,geom
),

calculate_risk as (
    SELECT
        id,
        vulnerability,
		exposure_hazard,
        (vulnerability*exposure_hazard*hazard_prob_weighted*prop_respuesta_weighted) as risk,
        personas_weighted,
        pobl_depend_weighted,
        conteo_sii_weighted,
        conteo_plantas_weighted,
        prop_respuesta_weighted,
        dist_hazard_weighted,
        near_ccaa_weighted,
        hazard_prob_weighted,
        prop_respuesta,
        hazard_prob,
        geom
    FROM
        calculate_vulnerability
),

min_max_risk as (
    SELECT
        MIN(risk) AS min_risk,
        MAX(risk) AS max_risk,
        MIN(exposure_hazard) AS min_exposure_hazard,
        MAX(exposure_hazard) AS max_exposure_hazard
    FROM 
		calculate_risk
),

normalization as (
    SELECT 
        id,
        vulnerability,
        exposure_hazard,
        prop_respuesta,
        hazard_prob,
        (risk.exposure_hazard - min_exposure_hazard) / (max_exposure_hazard - min_exposure_hazard) as exposure_hazard_norm,
        (risk.risk - min_risk) / (max_risk - min_risk) as risk_norm,
        risk,
        personas_weighted,
        pobl_depend_weighted,
        conteo_sii_weighted,
        conteo_plantas_weighted,
        prop_respuesta_weighted,
        dist_hazard_weighted,
        near_ccaa_weighted,
        hazard_prob_weighted,
        geom
    FROM calculate_risk as risk, min_max_risk as min_max
),

stats as (
  SELECT
    percentile_cont(0.5) WITHIN GROUP (ORDER BY risk) AS median_risk,
    percentile_cont(0.25) WITHIN GROUP (ORDER BY risk) AS q1_risk,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY risk) AS q3_risk
  FROM normalization
)

SELECT
    id,
    vulnerability,
    exposure_hazard,
    prop_respuesta,
    hazard_prob,
    exposure_hazard_norm,
    risk_norm,
    risk,
    personas_weighted,
    pobl_depend_weighted,
    conteo_sii_weighted,
    conteo_plantas_weighted,
    prop_respuesta_weighted,
    dist_hazard_weighted,
    near_ccaa_weighted,
    hazard_prob_weighted,
    (normalization.risk - stats.median_risk) /
        (stats.q3_risk - stats.q1_risk) AS risk_robust_scaled,
    geom
FROM
  normalization, stats