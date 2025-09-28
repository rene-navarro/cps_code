import psycopg2
import time
import csv
from datetime import datetime

def connect_to_db():
    try:
        connection = psycopg2.connect(
            dbname='northwind',
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
            # print("Connection closed successfully.")
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
        connection.commit()
        # print("Query executed successfully.")
        return cursor.fetchall()
    except psycopg2.Error as e:
        print(f"Error executing query: {e}")
        return None
    finally:
        cursor.close()  

def query_task():
    connection = connect_to_db()
    if connection:
        query = "SELECT count(orders.order_id) AS total FROM orders"
        results = execute_query(connection, query)
        # print("Rows returned:" + str(len(results)) if results else "0")
       
        if results is not None:
            current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) 
            # print(f"Query executed at: {current_time}")

            for row in results:
                print( current_time,row[0] )
                data = {'Time': current_time, 'Total Orders': row[0]}
                write_csv('query_results.csv', data)
        close_connection(connection)

def write_csv(filename, data):
  
    if data is None:
        print("No data to write to CSV.")
        return
    
    try:
        with open(filename, mode='a', newline='') as file:
            writer = csv.writer(file)
            # writer.writerow(data[0]._fields)  # Write header
            writer.writerow(data.values())  # Write data row
        # print(f"Data written to {filename} successfully.")
    except Exception as e:
        print(f"Error writing to CSV: {e}")

def main():
    stop_hour = 16  # 5 PM
    stop_minute = 56
    wait_time = 900  # Initial delay before starting the loop
    while True:
        current_hour = datetime.now().hour
        current_minute = datetime.now().minute
        if current_hour >= stop_hour and current_minute >= stop_minute:
            print("Stopping — reached stop hour.")
            break
        query_task()
        # Sleep for 15 minutes (900 seconds)
        time.sleep(30)

if __name__ == "__main__":
    main()
