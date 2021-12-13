generic_query = '''
                SELECT * 
                FROM tabla;
                '''


#aca ver bien cual será el formato de la tabla
ccaa_affected = f'''CREATE OR REPLACE TABLE ccaa_affected_{{id_closed_area}}_{{date}} AS ()
                    SELECT ST_Within(a.geom, c.)
                    FROM {{id_closed_area}} as a,
                    {{CCAA}} as c
                     '''

buffer = '''
            SELECT ST_Buffer(geom)
            FROM
        

                     '''

markets_affected = '''

                     '''