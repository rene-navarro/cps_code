import socket
import threading


def echo_service(client_socket, addr):
    try:
        while True:
            data = client_socket.recv(1024)
            response = data.decode("utf-8") # convert bytes to string
        
            # if we receive "." from the client, then we break
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
    except Exception as e:
        print(f"Error when hanlding client: {e}")
    finally:
        client_socket.close()
        print(f"Connection to client ({addr[0]}:{addr[1]}) closed")


def run_server():
    """Run a simple Echo Protocol/TCP server that accepts connections and
    responds to client messages."""
    server_ip = "127.0.0.1"  # server hostname or IP address
    port = 7777  # arbitrary non-privileged port, echo protocol uses port 7
    # create a socket object
    try:
        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # bind the socket to the host and port
        server.bind((server_ip, port))
        
        # listen for incoming connections
        server.listen()
        print(f"Listening on {server_ip}:{port}")

        max_clients = 5
        while max_clients > 0:
            # accept a client connection
            client_socket, addr = server.accept()
            print(f"Accepted connection from {addr[0]}:{addr[1]}")
            # start a new thread to handle the client
            thread = threading.Thread(target=echo_service, args=(client_socket, addr,))
            thread.start()
            max_clients -= 1
    except Exception as e:
        print(f"Error: {e}")
    finally:
        server.close()


def main():
    run_server()

if __name__ == "__main__":
    main()
