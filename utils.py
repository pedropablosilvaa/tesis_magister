def consulta_sql(database, user, password, host, port, query):
    '''Funcion que devuelve una query sql'''
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


def consulta_sql_pc(database, user, password, host, port, query):
    '''Funcion que devuelve una query sql'''
    #Ingreso de parametros de conexion
    con = psycopg2.connect(database = database, user = user, 
                           password = password, host = host, port = port)
    #Creacion de conexion
    cur = con.cursor()
    #Ejecuta la conexion
    cur.execute(query)
    #Ordena la consulta
    output = cur.fetchall()[0][0]
    print("Table of nodes created successfully")
    #Se cierra la conexion
    con.close()
    return output


if __name__ == '__main__':
    pass