import socket


def run_client():
    # create a socket object
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    server_ip = "127.0.0.1"  # replace with the server's IP address
    server_port = 1313  # datetime protocol uses port 13
    # establish connection with server
    
    client.connect((server_ip, server_port))

    # receive message from the server
    response = client.recv(1024)
    response = response.decode("utf-8")
    print(f"Received: {response}")

    # close client socket (connection to the server)
    client.close()
    print("Connection to server closed")

if __name__ == "__main__":
    run_client()
    