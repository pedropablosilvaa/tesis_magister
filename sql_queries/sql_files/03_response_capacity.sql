/*
Esta query tiene como objetivo obtener una tabla final 
con las geometrías, los nombres, y el valor de vulnerabilidad
espacial [0,1]  

*/


-- se elimina la capa de ruteo
DROP TABLE IF EXISTS capas_estaticas."response_capacity";

-- se crea la capa de ruteo
CREATE TABLE capas_estaticas."response_capacity" as 

WITH entidades_18s as (
    SELECT
        id,
        ST_Transform(geom, 32718) AS geom
    FROM 
        capas_estaticas."social_vulnerability"
),

empresas_acuicultura_18s as (
    SELECT
        ST_Transform(geom, 32718) AS geom
    FROM
        capas_estaticas."business_location_filtered"
),

empresas_total_18s as (
    SELECT
        ST_Transform(geom, 32718) AS geom
    FROM
        capas_estaticas."empresas_region"
),

empresas_sii_total as (
    SELECT
        entidad.id,
        entidad.geom AS entidad_geom,
        COUNT(empresas.geom) AS conteo_sii_total
    FROM 
        entidades_18s as entidad
    LEFT JOIN 
        empresas_total_18s AS empresas
    ON 
        ST_DWithin(entidad.geom,  empresas.geom, 500)
    GROUP BY
        entidad.id, entidad.geom
),

empresas_sii_acuicultura as (
    SELECT
        entidad.id,
        entidad.geom AS entidad_geom,
        COUNT(empresas.geom) AS conteo_sii_acuicultura
    FROM 
        entidades_18s as entidad
    LEFT JOIN 
        empresas_acuicultura_18s AS empresas
    ON 
        ST_DWithin(entidad.geom,  empresas.geom, 500)
    GROUP BY
        entidad.id, entidad.geom
),

final_empresas_sii_total as (
    SELECT 
        id,
        entidad_geom,
        conteo_sii_total
    FROM empresas_sii_total
),

final_empresas_sii_acuicultura as (
    SELECT 
        id,
        entidad_geom,
        conteo_sii_acuicultura
    FROM empresas_sii_acuicultura
),


join_empresas as (
    SELECT 
        final_empresas_sii_total.id,
        final_empresas_sii_total.entidad_geom,
        final_empresas_sii_total.conteo_sii_total,
        final_empresas_sii_acuicultura.conteo_sii_acuicultura
    FROM
        final_empresas_sii_total
    LEFT JOIN
        final_empresas_sii_acuicultura
    ON final_empresas_sii_total.id = final_empresas_sii_acuicultura.id
),

cast_values_entidad as (
    SELECT
        id,
		conteo_sii_total,
		conteo_sii_acuicultura,
        CAST(conteo_sii_total as numeric) as conteo_total,
        CAST(conteo_sii_acuicultura as numeric) as conteo_acuicultura,
        entidad_geom
    FROM	
		join_empresas
),

calculate_response as (
	SELECT
		id,
		CASE 
			WHEN conteo_total=0 THEN 0
			ELSE 1-(conteo_acuicultura/conteo_total) 
		 END as prop_respuesta,
		conteo_sii_total,
		conteo_sii_acuicultura,
		entidad_geom
	FROM cast_values_entidad
)

SELECT
    id,
    conteo_sii_total,
    conteo_sii_acuicultura,
    prop_respuesta,
    CASE 
        WHEN prop_respuesta  < 0.65 THEN 0.583
        WHEN (prop_respuesta  >= 0.65 AND prop_respuesta < 0.85) THEN 0.266
        WHEN (prop_respuesta  >= 0.85 AND prop_respuesta < 0.95) THEN 0.102
        WHEN (prop_respuesta  >= 0.95) THEN 0.048
    END AS prop_respuesta_weighted,
    entidad_geom
FROM calculate_response 
