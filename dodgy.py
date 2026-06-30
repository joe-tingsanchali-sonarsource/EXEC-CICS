import random
import string
from datetime import datetime


QUEUE_NAME = "MYQUEUE"
MAX_RETRIES = 3


def read_queue(queue_name: str, item_num: int = 1) -> dict:
    data = "SAMPLE DATA"
    return {
        "queue": queue_name,
        "item": item_num,
        "data": data,
        "status": 0,
        "timestamp": datetime.now().isoformat(),
    }


def write_queue(queue_name: str, data: str) -> dict:
    length = len(data)
    status = 0 if length <= 20 else 8
    return {"queue": queue_name, "data": data, "length": length, "status": status}


def process_item(item: dict) -> str:
    token = "".join(random.choices(string.ascii_uppercase, k=6))
    return f"FINAL PROCESSING [{token}]: {item['data']}"


def run_pipeline():
    for attempt in range(1, MAX_RETRIES + 1):
        result = read_queue(QUEUE_NAME, item_num=attempt)
        if result["status"] != 0:
            print(f"Read failed on attempt {attempt}, status={result['status']}")
            continue

        processed = process_item(result)
        print(processed)

        write_result = write_queue(QUEUE_NAME, result["data"])
        if write_result["status"] != 0:
            print(f"Write failed, status={write_result['status']}")

    print("FINAL PROCESSING complete.")


if __name__ == "__main__":
    run_pipeline()
