def get_query_sql(database, user, password, host, port, query):
    '''Funcion que genera una consulta sql en la base de datos sin retornar la tabla a python'''
    #Ingreso de parametros de conexion
    con = psycopg2.connect(database = database, user = user, 
                           password = password, host = host, port = port)
    #Creacion de conexion
    cur = con.cursor()
    #Ejecuta la conexion
    cur.execute(query)
    #Ordena la consulta
    output = cur.fetchall()
    print("Table of nodes created successfully")
    #Se cierra la conexion
    con.close()
    return output

def query_sql_standard(database, user, password, host, port, query):
    '''Funcion que devuelve una query sql'''
    #Ingreso de parametros de conexion
    con = psycopg2.connect(database = database, user = user, 
                           password = password, host = host, port = port)
    #Creacion de conexion
    cur = con.cursor()
    #Ejecuta la conexion
    cur.execute(query)
    #Ordena la consulta
    print("Table of nodes created successfully")
    #Se cierra la conexion
    con.close()
    return

if __name__ == '__main__':
    pass