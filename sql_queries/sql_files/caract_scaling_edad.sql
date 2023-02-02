/*

Esta query tiene como objetivo obtener una tabla final 
con las geometrías, los nombres, y el valor de vulnerabilidad
espacial [0,1]  

*/

-- se elimina la capa de ruteo
DROP TABLE IF EXISTS capas_estaticas.scaling_edad;

-- se crea la capa de ruteo
CREATE TABLE capas_estaticas.scaling_edad as 

WITH manzanas AS (
    SELECT
        "FID" as id,
        "COD_ENTIDA" as cod_entidad,
        "PROVINCIA" as provincia,
        "COMUNA" as comuna,
        "PERSONAS" as personas,
        "DE_0_A_5_A" as edad_0_5,
        "DE_65_MAS_" as edad_65_mas,
        geom as geom
    FROM 
        capas_estaticas."censo_2017_XR"
    WHERE
        "DE_0_A_5_A" <> 'Indeterminado'
        AND "DE_65_MAS_" <> 'Indeterminado'
),

cast_values_manz as (
    SELECT
        id,
        cod_entidad,
        provincia,
        comuna,
        personas,
        CAST(edad_0_5 as numeric) as edad_0_5,
        CAST(edad_65_mas as numeric) edad_65_mas,
        geom
    FROM	
		manzanas

),

-- Calcular el valor mínimo y máximo de la columna "poblacion"
min_max_manz AS (
    SELECT
        MIN(edad_0_5) AS min_edad_0_5,
        MAX(edad_0_5) AS max_edad_0_5, 
        MIN(edad_65_mas) AS min_edad_65_mas,
        MAX(edad_65_mas) AS max_edad_65_mas
    FROM 
		cast_values_manz

),

final_manz as (
    SELECT
		id,
        edad_0_5,
        edad_65_mas,
        (manz.edad_0_5 - min_edad_0_5) / (max_edad_0_5 - min_edad_0_5) as edad_0_5_norm,
        (manz.edad_65_mas - min_edad_65_mas) / (max_edad_65_mas - min_edad_65_mas) as edad_65_mas_norm ,
        geom
    FROM cast_values_manz as manz, min_max_manz 
),



--Desde acá en adelante se hace lo mismo, pero ahora para entidades  
entidad AS (
    SELECT
        "FID" as id,
        "COD_ENTIDA" as cod_entidad,
        "PROVINCIA" as provincia,
        "COD_COMUNA" as comuna,
        "PERSONAS" as personas,
        "DE_0_A_5_A" as edad_0_5,
        "DE_65_MAS_" as edad_65_mas,
        geom as geom_entidad
    FROM 
        capas_estaticas."entidades_2017_XR"
    WHERE
        "DE_0_A_5_A" <> 'Indeterminado'
        AND "DE_65_MAS_" <> 'Indeterminado'
),

cast_values_entidad as (
    SELECT
        id,
        cod_entidad,
        provincia,
        comuna,
        personas,
        CAST(edad_0_5 as numeric) as edad_0_5,
        CAST(edad_65_mas as numeric) edad_65_mas,
        geom_entidad
    FROM	
		entidad

),

-- Calcular el valor mínimo y máximo de la columna "poblacion"
min_max_entidad AS (
    SELECT
        MIN(edad_0_5) AS min_edad_0_5,
        MAX(edad_0_5) AS max_edad_0_5, 
        MIN(edad_65_mas) AS min_edad_65_mas,
        MAX(edad_65_mas) AS max_edad_65_mas
    FROM 
		cast_values_entidad

),

final_entidad as (
    SELECT
		id,
        edad_0_5,
        edad_65_mas,
        (entidad.edad_0_5 - min_edad_0_5) / (max_edad_0_5 - min_edad_0_5) as edad_0_5_norm,
        (entidad.edad_65_mas - min_edad_65_mas) / (max_edad_65_mas - min_edad_65_mas) as edad_65_mas_norm,
        geom_entidad
    FROM cast_values_entidad as entidad, min_max_entidad as min_max 
)

SELECT
	id,
    edad_0_5,
    edad_65_mas,
    edad_0_5_norm,
    edad_65_mas_norm,
	geom
FROM 
    final_manz
UNION ALL
SELECT * FROM final_entidad

