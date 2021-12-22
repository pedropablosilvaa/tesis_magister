import os
import pathlib
import sql_queries.consultas_sql as consultas_sql

def main():
    current_path = str(pathlib.Path(__file__).parent.absolute())
    #my_path = os.path.join(current_path, 'out', 'csv')
    lista = os.listdir(current_path)
    print(lista)


if __name__ == '__main__':
    main()

#python3 test.py