import psycopg2

def connect_to_db():
    try:
        connection = psycopg2.connect(
            dbname='dreamhome',
            user = "developer", 
            host= 'localhost',
            password = "codemonkey",
            port = 5432)
        return connection
    except psycopg2.Error as e:
        print(f"Error connecting to the database: {e}")
        return None 
    
def close_connection(connection):
    if connection:
        try:
            connection.close()
            print("Connection closed successfully.")
        except psycopg2.Error as e:
            print(f"Error closing the connection: {e}")
    else:
        print("No connection to close.")

def execute_query(connection, query):
    if connection is None:
        print("No connection to execute the query.")
        return None
    
    try:
        cursor = connection.cursor()
        cursor.execute(query)
        print( cursor.description[0] )  # Print column names
        connection.commit()
        print("Query executed successfully.")
        return cursor.fetchall()
    except psycopg2.Error as e:
        print(f"Error executing query: {e}")
        return None
    finally:
        cursor.close()  

def main():
    connection = connect_to_db()
    if connection:
        query = "SELECT * FROM staff;"
        results = execute_query(connection, query)
        print("Rows returned:" + str(len(results)) if results else "0")
       
        if results is not None:
            for row in results:
                print(row)
        close_connection(connection)

if __name__ == "__main__":
    main()
