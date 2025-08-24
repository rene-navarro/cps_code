import socket
from datetime import datetime

def run_server():
    """Run a simple Daytime Protocol/TCP server that accepts connections and 
    responds to client messages."""
    # create a socket object
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    server_ip = "127.0.0.1"
    # datetime protocol uses port 13
    port = 1313

    # bind the socket to a specific address and port
    server.bind((server_ip, port))
    # listen for incoming connections
    server.listen(0)
    print(f"Listening on {server_ip}:{port}")

    count = 0
    # receive data from the client
    while count in range(5):
        print("Waiting for a connection...")
         # accept incoming connections
        client_socket, client_address = server.accept()
        print(f"Accepted connection from {client_address[0]}:{client_address[1]}")

        
        today = datetime.now()
        date_time = today.strftime("%A, %B %d, %Y, %H:%M:%S")
        print(f"Sending date and time: {date_time}")
        # send current date and time to the client
        client_socket.send(date_time.encode("utf-8"))

        # close connection socket with the client
        client_socket.close()
        print("Connection to client closed")
        count += 1
    # close server socket
    server.close()

def main():
    run_server()

if __name__ == "__main__":
   main()
    