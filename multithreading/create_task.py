import asyncio
import requests
import time

words_histogram = dict()

async def fetch_url(url):
    print(f"Starting to fetch {url}")
    response = requests.get(url)
    print(f"Finished fetching {url} with status code {response.status_code}")
    return response.text

async def main(urls):
    tasks = []
    for url in urls:
        task = asyncio.create_task(fetch_url(url))
        tasks.append(task)
    await asyncio.gather(*tasks)
    for task in tasks:
        content = task.result()
        words = content.split()
        for word in words:
            word = word.lower()
            if word in words_histogram:
                words_histogram[word] += 1
            else:
                words_histogram[word] = 1

if __name__ == "__main__":
    urls = [
        "https://www.gutenberg.org/cache/epub/84/pg84.txt",
        "https://www.gutenberg.org/cache/epub/345/pg345.txt",
        "https://www.gutenberg.org/cache/epub/41537/pg41537.txt",
        "https://www.gutenberg.org/cache/epub/16452/pg16452.txt",
       
    ]
    
    start = time.perf_counter()
    asyncio.run(main(urls))
    end = time.perf_counter()
    
    print("All URLs have been fetched.")
    print(f"Time taken with asyncio: {end - start:.2f} seconds")
    print(f"Total unique words: {len(words_histogram)}")
    most_common_words = sorted(words_histogram.items(), key=lambda x: x[1], reverse=True)[:10]
    print("Most common words:")
    for word, count in most_common_words:
        print(f"{word}: {count}")