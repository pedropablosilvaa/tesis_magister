import os
import sql_queries.consultas_sql as consultas_sql

def main():
    query = consultas_sql.ccaa_affected.format(hola='porelñackson')
    print(query)


if __name__ == '__main__':
    main()

#python3 test.py