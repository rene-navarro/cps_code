import socket

def run_server():
    """Run a simple Echo Protocol/TCP server that accepts connections and
    responds to client messages."""

    # create a socket object
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    server_ip = "127.0.0.1"
    port = 7777 # arbitrary non-privileged port, echo protocol uses port 7

    # bind the socket to a specific address and port
    server.bind((server_ip, port))
    # listen for incoming connections
    server.listen(0)
    print(f"Listening on {server_ip}:{port}")

    # accept incoming connections
    client_socket, client_address = server.accept()
    print(f"Accepted connection from {client_address[0]}:{client_address[1]}")

    # receive data from the client
    while True:
        data = client_socket.recv(1024)
        response = data.decode("utf-8") # convert bytes to string
        
        # if we receive "close" from the client, then we break
        # out of the loop and close the conneciton
        if response.lower() == ".":
            # send response to the client which acknowledges that the
            # connection should be closed and break out of the loop
            client_socket.send("closed".encode("utf-8"))
            break

        print(f"Received: {response}")

        data = response.encode("utf-8") # convert string to bytes
        # convert and send accept response to the client
        client_socket.send(data)

    # close connection socket with the client
    client_socket.close()
    print("Connection to client closed")
    # close server socket
    server.close()

def main():
    run_server()

if __name__ == "__main__":
   main()
   
