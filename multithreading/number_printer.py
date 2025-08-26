import threading
import time
import random

class NumberPrinter(threading.Thread):
    def __init__(self, thread_name):
        super().__init__()
        self.thread_name = thread_name

    def run(self):
        for i in range(5):
            sleep_time = random.randint(1, 5)
            print(f"{self.thread_name} prints {i} (sleeping {sleep_time} seconds)")
            time.sleep(sleep_time)

def main():
    # Create two threads
    thread1 = NumberPrinter("Thread-1")
    thread2 = NumberPrinter("Thread-2")

    # Start the threads
    thread1.start()
    thread2.start()

    # Wait for both threads to finish
    thread1.join()
    thread2.join()

    print("Both threads finished execution!")