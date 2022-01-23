#para manejo de BD
import pandas as pd
# para calculo numerico
import numpy as np
# para PpostgresSQL
import psycopg2
# para calcular tiempos
import time
import os
from os import listdir
from os.path import isfile, join
#Para graficar
import matplotlib.pyplot as plt
from matplotlib.pyplot import figure
from config import database_param
import utils
import argparse
import sql_queries.consultas_sql as consultas_sql

pd.set_option('display.float_format', '{:.5f}'.format)
DATABASE=database_param["database"]
USER=database_param["user"]
PASSWORD=database_param["password"]
HOST=database_param["host"]
PORT=database_param["port"]

parser = argparse.ArgumentParser(description='Preprocessing of spatial data')
parser.add_argument("--buffer_dist", dest="buffer_dist", required=True, type=str, help="Distance in meters of buffer diameter")
parser.add_argument("--id_closed_area",  Ist="id_closed_area", required=True, type=str, help="id of closed area to analize")
parser.add_argument("--id_ccaa_layer", dest="id_closed_area", required=True, type=str, help="id of closed area to analize")
parser.add_argument("--year", dest="year", required=True, type=str, help="year to analize")
parser.add_argument("--month", dest="month", required=True, type=str, help="FloydWarshall or Johnsons algorithm")
parser.add_argument("--day", dest="day", required=True, type=str, help="FloydWarshall or Johnsons algorithm")


#SELECT BY LOCATION
#BUFFER
#SELECT BY LOCATION ON BUFFER
#ISOCHRONES
#RISK ASSESSMENT

MARKET_LAYER = 'public.markets'


def select_markets_affected(id_ccaa_layer, id_closed_area, dist_buffer):
    ''' Select markets affected by closed areas
        input:  closed_area = id of closed area to analize
        dist_buffer = distance of buffer from CCAA affected'''

    #Selection by location --> CCAA in closed area aka CCAA affected
    query_markets_affecteds = consultas_sql.get_markets_affected.format(
                                                        ccaa_layer = id_ccaa_layer,
                                                        closed_area_layer=id_closed_area,
                                                        buffer_dist = dist_buffer,
                                                        markets_layer = MARKET_LAYER)
    utils.query_sql_standard(DATABASE, USER, PASSWORD, HOST, PORT, query_markets_affecteds)
    return  


def main(n, n_chunks):
    start_time = time.time()
    args = parser.parse_args()
    id_closed_area = args.id_closed_area
    buffer_dist = args.buffer_dist
    id_ccaa_layer = args.id_ccaa_layer
    select_markets_affected(id_ccaa_layer, id_closed_area, buffer_dist)
    print('El tiempo de ejecucion fue de',
                (time.time() - start_time),
                'segundos.')
    return print('proceso terminado')


if __name__ == '__main__':
    main()
    #python3 calculate_dpc_nodes.py --nodes=all --route_algtm=floydwarshall  