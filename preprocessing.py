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
import sql_queryes.consultas_sql as consultas_sql

pd.set_option('display.float_format', '{:.5f}'.format)
database=database_param["database"]
user=database_param["user"]
password=database_param["password"]
host=database_param["host"]
port=database_param["port"]

parser = argparse.ArgumentParser(description='Preprocessing of spatial data')
#parser.add_argument("--nodes", dest="nodes", required=True, type=str, help="'all' to calculate dPC for all nodes")
#parser.add_argument("--n_chunks", dest="n_chunks", required=True, type=str, help="number of chunks to split data")
#parser.add_argument("--route_algtm", dest="route_algtm", required=True, type=str, help="FloydWarshall or Johnsons algorithm")



def calculate_dpc(node, n_chunks):
    node_list = utils.consulta_sql(database, user, password, host, port, consultas_sql.node_list_query)
    node_list = pd.DataFrame.from_records(node_list,
                                          columns = ['idv'])
    if node == 'all':
        chunks = np.array_split(node_list, n_chunks)
        for chunk in chunks:
            resultados_dpc = []
            for nodo in node_list:
                resultados_dpc.append(calculate_pc(node))
            node_list_chunk = chunks[chunk]['idv'].values.tolist()
            df = pd.DataFrame(list(zip(node_list_chunk, resultados_dpc)),
                            columns =['idv', 'newPC'])
            nameFile = os.path.join(os.path.dirname(__file__),'resultados',f'chunk_{chunk}.csv')
            df.to_csv(nameFile, sep=';')
        
    else:
        pc = calculate_pc(node)
    return pc
        

def calculate_pc(nodo):
    query_file = open(os.path.join(os.path.dirname(__file__),'consultas_sql','calculate_dPC.sql'),'r')
    query = query_file.read().format(nodo=nodo)
    pc = utils.consulta_sql_pc(database, user, password, host, port, query)
    return pc

def dfUnion():
    '''Funcion que une los df pequenos en uno'''
    pathChunks = f'\\resultados_parciales'
    nameFile = f'\\resultados'
    onlyFiles = [f for f in listdir(nameFile) if isfile(join(nameFile, f))]

    data_new = pd.read_csv(nameFile + '\\' + onlyFiles[0], sep = ';')

    for file in range(len(onlyFiles))[1:]:
        data_old = data_new
        data_new = pd.read_csv(nameFile + '\\' + onlyFiles[file], sep = ';')
        data_new = pd.concat([data_old, data_new])

    data_new.to_csv(pathChunks + '\\' + 'chunksJoin.csv', sep=';')    


def main(n, n_chunks):
    start_time = time.time()
    args = parser.parse_args()
    node = args.nodes
    n_chunks = args.n_chunks
    calculate_dpc(node, n_chunks)
    dfUnion()
    print('El tiempo de ejecucion fue de',
                (time.time() - start_time),
                'segundos.')
    return print('proceso terminado')


if __name__ == '__main__':
    main()
    #python3 calculate_dpc_nodes.py --nodes=all --route_algtm=floydwarshall  

