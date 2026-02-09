import os
import requests

# List of Tesseract language codes used in your app.py
LANGS = [
    "afr", "amh", "ara", "asm", "aze", "aze_cyrl", "bel", "ben", "bod", "bos", "bre", "bul",
    "cat", "ceb", "ces", "chi_sim", "chi_sim_vert", "chi_tra", "chi_tra_vert", "chr", "cos",
    "cym", "dan", "deu", "deu_latf", "div", "dzo", "ell", "eng", "enm", "epo", "equ", "est",
    "eus", "fao", "fas", "fil", "fin", "fra", "frm", "fry", "gla", "gle", "glg", "grc", "guj",
    "hat", "heb", "hin", "hrv", "hun", "hye", "iku", "ind", "isl", "ita", "ita_old", "jav",
    "jpn", "jpn_vert", "kan", "kat", "kat_old", "kaz", "khm", "kir", "kmr", "kor", "lao",
    "lat", "lav", "lit", "ltz", "mal", "mar", "mkd", "mlt", "mon", "mri", "msa", "mya", "nep",
    "nld", "nor", "oci", "ori", "osd", "pan", "pol", "por", "pus", "que", "ron", "rus", "san",
    "sin", "slk", "slv", "snd", "spa", "spa_old", "sqi", "srp", "srp_latn", "sun", "swa",
    "swe", "syr", "tam", "tat", "tel", "tgk", "tha", "tir", "ton", "tur", "uig", "ukr", "urd",
    "uzb", "uzb_cyrl", "vie", "yid", "yor"
]

# Using tessdata_fast for better speed and smaller size
BASE_URL = "https://github.com/tesseract-ocr/tessdata_fast/raw/main/"
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