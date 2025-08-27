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

def insert_branch(connection, branch_no, street, city, postcode):
    if connection is None:
        print("No connection to execute the query.")
        return None
    
    query = """
    INSERT INTO branch (branch_no, street, city, postcode)
    VALUES (%s, %s, %s, %s);
    """
    
    try:
        cursor = connection.cursor()
        cursor.execute(query, (branch_no, street, city, postcode))
        connection.commit()
        print("Branch inserted successfully.")
    except psycopg2.Error as e:
        print(f"Error inserting branch: {e}")
    finally:
        cursor.close()

def main():
    connection = connect_to_db()
    if connection:
        # Example data to insert
        branch_no = input ("Enter branch number (B999): ")
        street = input ("Enter street: ")
        city = input ("Enter city: ")
        postcode = input ("Enter postcode: ")
        
        insert_branch(connection, branch_no, street, city, postcode)
        close_connection(connection)