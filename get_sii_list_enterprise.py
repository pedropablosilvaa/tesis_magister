#para manejo de tablas
import pandas as pd
import numpy as np
# para PpostgresSQL
import psycopg2
# para calcular tiempos
import time
import os
from os import listdir
from os.path import isfile, join
from config import database_param
import utils
import argparse
import sql_queries.consultas_sql as consultas_sql
import geocoder

pd.set_option('display.float_format', '{:.5f}'.format)
DATABASE=database_param["database"]
USER=database_param["user"]
PASSWORD=database_param["password"]
HOST=database_param["host"]
PORT=database_param["port"]

#parser = argparse.ArgumentParser(description='Preprocessing of spatial data')
#parser.add_argument("--buffer_dist", dest="buffer_dist", required=True, type=str, help="Distance in meters of buffer diameter")


def get_sii_list_enrerprise():
    ''' descripcion: read, transform and upload to DB of list of enterprises for X Region.
        input:  
            3 file from SII web
            PUB_EMPRESAS_PJ_2020.txt
            WEB_DOMICILIOS_202106.txt
            WEB_SUCURSALES_202106.txt

    '''

    main_path = os.path.dirname(os.path.abspath(__file__))
    path_sii = os.path.join(main_path, "data", "sii")
    
    #Get path of txt files
    path_detail = os.path.join(main_path, "data", "sii", "PUB_EMPRESAS_PJ_2020.txt")
    path_location_matriz = os.path.join(main_path, "data", "sii", "WEB_DIRECCIONES_202106", "WEB_DOMICILIOS_202106.txt")
    path_location_sucursal = os.path.join(main_path, "data", "sii", "WEB_DIRECCIONES_202106", "WEB_SUCURSALES_202106.txt")
    
    #Parsing txt file to pandas csv
    df_detail = pd.read_csv(path_detail, sep = "	", encoding='latin-1')
    df_location_matriz = pd.read_csv(path_location_matriz, sep = "	", encoding='latin-1')
    df_location_sucursal = pd.read_csv(path_location_sucursal, sep = "	", encoding='latin-1')
    
    #Some filters
    df_location = df_location_sucursal.append(df_location_matriz)
    df_region_detail = df_detail[df_detail.Región == 'X REGION LOS LAGOS']
    df_region_location = df_location[(df_location.Region == 'X REGION LOS LAGOS') & (df_location.Vigencia == 'S')]
    df_with_location =  df_region_detail.join(df_region_location.set_index('Rut'), on = 'RUT',how = 'left', lsuffix='_l', rsuffix='_r')
    
    #Geocoding
    start_time = time.time()
    sii = df_with_location.applymap(str)
    #uncomment follow line to sample df in n rows
    #sii = sii.sample(n = 20)
    x = []
    y = []
    for i in range(len(sii)):
        if sii['Ciudad'].iloc[i] == 'nan' and sii['Numero'].iloc[i] == 'nan':
            address = sii['Calle'].iloc[i] + ', ' + sii['Comuna_r'].iloc[i] + ', ' + 'Los Lagos Region'
        elif sii['Ciudad'].iloc[i] == 'nan':
            address = sii['Calle'].iloc[i] + ', ' + sii['Comuna_r'].iloc[i] + ', ' + 'Los Lagos Region'
        else:
            address = sii['Calle'].iloc[i] + ' ' + sii['Numero'].iloc[i] + ', ' + sii['Ciudad'].iloc[i] + ', ' + 'Los Lagos Region'
        
        print(address)        
        if len(geocoder.osm(address)) != 0:
            x.append(geocoder.osm(address).osm['x'])
            y.append(geocoder.osm(address).osm['y'])
        else:
            x.append(0)
            y.append(0)
    sii['lon'] = x
    sii['lat'] = y
    time_execution = time.time() - start_time
    print(f"{len(sii)} points was processing in {time_execution} seconds of time execution.")
    #Exporting
    final_path = os.path.join(path_sii, "business_location.csv")
    sii.to_csv(final_path)



'''
    #Selection by location --> CCAA in closed area aka CCAA affected
    query_markets_affecteds = consultas_sql.get_markets_affected.format(
                                                        ccaa_layer = id_ccaa_layer,
                                                        closed_area_layer=id_closed_area,
                                                        buffer_dist = dist_buffer,
                                                        markets_layer = MARKET_LAYER)
    utils.query_sql_standard(DATABASE, USER, PASSWORD, HOST, PORT, query_markets_affecteds)
    return  
'''

def main():
    start_time = time.time()
    get_sii_list_enrerprise()
    #args = parser.parse_args()
    #id_closed_area = args.id_closed_area
    print('Time of execution',
                (time.time() - start_time),
                'seconds.')
    return print('Process end')


if __name__ == '__main__':
    main()
    #python3 get_sii_list_enterprise.py