generic_query = '''
                SELECT * 
                FROM tabla;
                '''


#aca ver bien cual será el formato de la tabla
within = f'''CREATE OR REPLACE TABLE {{output_table}} AS (
                    SELECT ST_Within(a.geom, c.geom)
                    FROM {{layer_1}} as a,
                    {{layer_2}} as c
                    )
                     '''                  

buffer = f'''
            CREATE OR REPLACE TABLE {{output_table}} AS (
            SELECT ST_Buffer(geom)
            FROM {{id_closed_area}}
         '''

get_markets_affected =  f'''
                        CREATE OR REPLACE table_name
                        WITH select_ccaa as (
                           SELECT a.*, 
                           ST_WITHIN(a.geom, c.geom) as intersect
                           FROM {{ccaa_layer}} as a,
                           {{closed_area_layer}} as c 
                           WHERE intersect = TRUE
                        ),

                        buffer_ccaa as (
                           SELECT ST_BUFFER(geom, {{buffer_dist}})
                           FROM select_ccaa
                        )

                        SELECT a.*,
                        ST_WITHIN(a.geom, c.geom) as is_affected
                        FROM {{markets_layer}} as a,
                        buffer_ccaa as c
                        WHERE is_affected = TRUE
                        ),
                        '''