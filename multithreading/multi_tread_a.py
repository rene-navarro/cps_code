import threading
import time
import requests 

def fetch_url(url):
    print(f"Starting to fetch {url}")
    response = requests.get(url)
   
    print(f"Finished fetching {url} with status code {response.status_code}")

if __name__ == "__main__":
    urls = [
        "https://www.gutenberg.org/",
        "https://www.python.org",
        "https://www.github.com",
        "https://www.stackoverflow.com",
        "https://www.reddit.com"
    ]
    
    start = time.perf_counter()
    for url in urls:
        fetch_url(url)
    end = time.perf_counter()
    print(f"Time taken without threading: {end - start:.2f} seconds")   

    threads = []
    start = time.perf_counter()
    for url in urls:
        thread = threading.Thread(target=fetch_url, args=(url,))
        threads.append(thread)
        thread.start()
    
    for thread in threads:
        thread.join()
    end = time.perf_counter()

    print("All URLs have been fetched.")
    print(f"Time taken with threading: {end - start:.2f} seconds")   