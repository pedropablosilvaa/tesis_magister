-- se elimina la capa de ruteo
DROP TABLE IF EXISTS capas_estaticas.risk;

-- se crea la capa de ruteo
CREATE TABLE capas_estaticas.risk as 

WITH consolidated_table as (
    SELECT
        social_vulnerability.id,
        social_vulnerability.edad_0_5_norm,
        social_vulnerability.edad_65_mas_norm,
        social_vulnerability.personas_norm,
        economic_vulnerability.sii_norm,
        economic_vulnerability.plantas_norm,
        hazard.hazard_norm,
        social_vulnerability.geom
    FROM
       capas_estaticas."social_vulnerability" as social_vulnerability
    LEFT JOIN
       capas_estaticas."economic_vulnerability" as economic_vulnerability
    ON social_vulnerability.id = economic_vulnerability.id
    LEFT JOIN
        capas_estaticas."exposure_to_hazard" as hazard
    ON social_vulnerability.id = hazard.id
),

calculate_vulnerability as (
    SELECT
        id,
        SUM(edad_0_5_norm*0.1 + edad_65_mas_norm*0.1 + plantas_norm*0.3 + plantas_norm*0.2+sii_norm*0.3) as vulnerability,
        hazard_norm,
        geom
    FROM
        consolidated_table
    group by id, hazard_norm, edad_0_5_norm, edad_65_mas_norm, plantas_norm, sii_norm, geom
)

SELECT
    id,
    vulnerability,
    vulnerability*(1-hazard_norm) as risk,
	geom
FROM
    calculate_vulnerability