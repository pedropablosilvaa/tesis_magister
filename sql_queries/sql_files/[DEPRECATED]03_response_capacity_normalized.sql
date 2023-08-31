/*
Esta query tiene como objetivo obtener una tabla final 
con las geometrías, los nombres, y el valor de vulnerabilidad
espacial [0,1]  

*/


-- se elimina la capa de ruteo
DROP TABLE IF EXISTS capas_estaticas.response_capacity_normalized;

-- se crea la capa de ruteo
CREATE TABLE capas_estaticas.response_capacity_normalized as 

WITH entidades_18s as (
    SELECT
        id,
        conteo_sii_total,
        conteo_sii_acuicultura,
        prop_respuesta,
        entidad_geom
    FROM 
        capas_estaticas."response_capacity"
),



select * from calculate_response


/*
cast_values_entidad as (
    SELECT
        id,
        CAST(conteo_sii_total as numeric) as conteo_total,
        CAST(conteo_sii_acuicultura as numeric) as conteo_acuicultura,
        entidad_geom
    FROM	
		join_empresas
),

-- Calcular el valor mínimo y máximo de la columna "poblacion"
min_max_entidad AS (
    SELECT
        MIN(conteo_total) AS min_total,
        MAX(conteo_total) AS max_total, 
        MIN(conteo_acuicultura) AS min_acc,
        MAX(conteo_acuicultura) AS max_acc
    FROM 
		cast_values_entidad
),

final_entidad as (
    SELECT
		id,
        conteo_total,
        conteo_acuicultura,
        (entidad.conteo_total - min_total) / (max_total - min_total) as empresas_total_norm,
        (entidad.conteo_acuicultura - min_acc) / (max_acc - min_acc) as empresas_acc,
        entidad_geom
    FROM cast_values_entidad as entidad, min_max_entidad as min_max 
),

fix_zero_values as (
	SELECT
		id, 
		CASE 
			WHEN conteo_total=0 THEN 0.01
		END AS conteo_total,
		CASE 
			WHEN conteo_acuicultura=0 THEN 0.01
		END AS conteo_acuicultura,
		entidad_geom
	FROM cast_values_entidad
)


    fix_zero_values
*/
