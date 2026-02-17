import os
import requests

# List of Tesseract language codes used in your app.py
LANGS = [
    # Major Indian Languages
    "hin", "mar", "ben", "guj", "tam", "tel", "kan", "mal", "pan", "urd", "nep", "san", "asm", "ori",

    # Major Global Languages
    "ara", "chi_sim", "chi_tra", "deu", "fra", "ita", "jpn", "kor", "nld",
    "por", "rus", "spa", "tha", "tur", "vie",

    # Other useful languages from your list
    "ind", "pol", "ukr", "ron", "ell", "ces", "swe", "hun", "heb", "msa", "fas"
]

# Using standard tessdata for better ACCURACY (fixes missing fonts/gibberish)
# tessdata_fast is faster but less accurate.
BASE_URL = "https://github.com/tesseract-ocr/tessdata/raw/main/"
OUTPUT_DIR = "tessdata"

def download_file(lang):
    filename = f"{lang}.traineddata"
    url = BASE_URL + filename
    path = os.path.join(OUTPUT_DIR, filename)
    
    if os.path.exists(path):
        print(f"Skipping {filename} (already exists)")
        return

    print(f"Downloading {filename}...")
    try:
        response = requests.get(url, stream=True)
        if response.status_code == 200:
            with open(path, 'wb') as f:
                for chunk in response.iter_content(1024):
                    f.write(chunk)
        else:
            print(f"Failed to download {filename}: HTTP {response.status_code}")
    except Exception as e:
        print(f"Error downloading {filename}: {e}")

if __name__ == "__main__":
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
    
    print("Starting download of Tesseract language files...")
    
    # Always download English and OSD (Orientation Script Detection)
    download_file("eng")
    download_file("osd")
    
    for lang in LANGS:
        download_file(lang)
        
    print("Download complete. Files saved to 'tessdata' folder.")