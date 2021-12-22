generic_query = '''
                SELECT * 
                FROM tabla;
                '''


#aca ver bien cual será el formato de la tabla
within = f'''CREATE OR REPLACE TABLE {{output_table}} AS (
                    SELECT ST_Within(a.geom, c.geom)
                    FROM {{layer_1}} as a,
                    {{ayer_2}} as c
                    )
                     '''                  

buffer = '''
            CREATE OR REPLACE TABLE {{output_table}} AS (
            SELECT ST_Buffer(geom)
            FROM {{id_closed_area}}
         '''