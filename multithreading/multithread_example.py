import threading
import time
import random

def print_numbers(thread_name):
    for i in range(5):
        sleep_time = random.randint(1, 5)
        print(f"{thread_name} prints {i} (sleeping {sleep_time} seconds)")
        time.sleep(sleep_time)

def main():
           
    # Create two threads
    thread1 = threading.Thread(target=print_numbers, args=("Thread-1",))
    thread2 = threading.Thread(target=print_numbers, args=("Thread-2",))

    # Start the threads
    thread1.start()
    thread2.start()

    # Wait for both threads to finish
    thread1.join()
    thread2.join()

    print("Both threads finished execution!")

if __name__ == "__main__":
    main()

