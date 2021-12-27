import os
import pathlib
import sql_queries.consultas_sql as consultas_sql

ccaa_layer = 'hola'
id_closed_area = 'mazo'
dist_buffer = 'sadas'
markets_layer = 'godines'

def main():
    query_1 = consultas_sql.get_markets_affected.format(ccaa_layer = ccaa_layer,
                                                        closed_area_layer=id_closed_area,
                                                        buffer_dist = dist_buffer,
                                                        markets_layer = markets_layer)
    print(query_1)


if __name__ == '__main__':
    main()

#python3 test.py