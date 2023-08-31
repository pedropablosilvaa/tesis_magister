DROP TABLE IF EXISTS capas_estaticas.raw_variables;

-- se crea la capa de ruteo
CREATE TABLE capas_estaticas.raw_variables as 


SELECT 
    social.id, 
    social.personas, 
    social.pobl_depend,
    economic.conteo_sii,
    economic.conteo_plantas,
    hazard.dist_hazard,
    response.prop_respuesta
FROM 
    capas_estaticas.social_vulnerability as social
JOIN
    capas_estaticas.economic_vulnerability as economic
    USING(id)
JOIN 
    capas_estaticas.exposure_to_hazard as hazard
    USING(id)
JOIN 
    capas_estaticas.response_capacity as response
    USING(id)




--SELECT (col - percentile_cont(0.5) WITHIN GROUP (ORDER BY col) OVER ()) / (percentile_cont(0.75) WITHIN GROUP (ORDER BY col) OVER () - percentile_cont(0.25) WITHIN GROUP (ORDER BY col) OVER ()) AS col_scaled
--FROM my_table;