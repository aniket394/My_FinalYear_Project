# Deployed URL: https://my-finalyear-project.onrender.com
from flask import Flask, request, jsonify
from flask_cors import CORS
from deep_translator import GoogleTranslator
import os, docx, PyPDF2, io
import re
from PIL import Image, ImageOps, ImageEnhance
import pytesseract, shutil
from functools import lru_cache
import gc

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

# -------------------------
# TESSERACT CONFIGURATION
# -------------------------
# --- MANUAL OVERRIDE FOR WINDOWS ---
# If Tesseract is still not found after reinstalling, uncomment the line below.
# tesseract_path_manual = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
tesseract_path_manual = None # Keep this as None if auto-detection works.

# Only use the manual path if it actually exists (prevents breaking Linux/Render)
if tesseract_path_manual and not os.path.exists(tesseract_path_manual):
    tesseract_path_manual = None

# --- AUTO-DETECTION ---
tesseract_path = tesseract_path_manual or shutil.which("tesseract")

if not tesseract_path:
    # Fallback to check common paths for Docker (Linux) and Windows
    possible_paths = [
        "/usr/bin/tesseract",                                      # Linux (Standard)
        "/usr/local/bin/tesseract",                                # Linux (Alternative)
    ]

    if os.name == 'nt': # Windows only checks
        possible_paths.extend([
            r"C:\Program Files\Tesseract-OCR\tesseract.exe",
            r"C:\Program Files (x86)\Tesseract-OCR\tesseract.exe",
        ])

    for path in possible_paths:
        exists = os.path.exists(path)
        print(f"Checking path: {path} -> {'Found' if exists else 'Not Found'}")
        if exists:
            tesseract_path = path
            break

if tesseract_path:
    pytesseract.pytesseract.tesseract_cmd = tesseract_path
    print(f"Tesseract found at: {tesseract_path}")

    # Check for local tessdata folder (downloaded by script)
    local_tessdata = os.path.join(os.getcwd(), "tessdata")
    if os.path.exists(local_tessdata):
        os.environ["TESSDATA_PREFIX"] = local_tessdata
        print(f"Using local tessdata from: {local_tessdata}")
else:
    print("WARNING: Tesseract not found. OCR may fail.")

# -------------------------
# LANGUAGE CODES (50+)
# -------------------------
lang_codes = {
    # Indian Languages
    "Hindi": "hi", "Marathi": "mr", "Bengali": "bn", "Gujarati": "gu",
    "Tamil": "ta", "Telugu": "te", "Kannada": "kn", "Malayalam": "ml",
    "Punjabi": "pa", "Urdu": "ur", "Odia": "or", "Assamese": "as",
    "Maithili": "mai", "Santali": "sat", "Kashmiri": "ks", "Nepali": "ne",
    "Konkani": "gom", "Sindhi": "sd", "Dogri": "doi", "Manipuri": "mni",
    "Bodo": "brx", "Sanskrit": "sa", "Bhojpuri": "bho",

    # Global languages
    "English": "en", "French": "fr", "Spanish": "es", "German": "de",
    "Chinese": "zh", "Japanese": "ja", "Korean": "ko", "Russian": "ru",
    "Arabic": "ar", "Portuguese": "pt", "Italian": "it", "Dutch": "nl",
    "Turkish": "tr", "Vietnamese": "vi", "Thai": "th", "Indonesian": "id",
    "Polish": "pl", "Ukrainian": "uk", "Romanian": "ro", "Greek": "el",
    "Czech": "cs", "Swedish": "sv", "Hungarian": "hu", "Hebrew": "he",
    "Malay": "ms", "Persian": "fa", "Filipino": "tl", "Finnish": "fi",
    "Danish": "da", "Norwegian": "no", "Swahili": "sw", "Afrikaans": "af",
    "Sinhala": "si", "Burmese": "my", "Khmer": "km", "Lao": "lo",
    
    # Extended Languages
    "Amharic": "am", "Azerbaijani": "az", "Belarusian": "be", "Tibetan": "bo", "Bosnian": "bs",
    "Bulgarian": "bg", "Catalan": "ca", "Cebuano": "ceb", "Corsican": "co", "Welsh": "cy",
    "Esperanto": "eo", "Estonian": "et", "Basque": "eu", "Frisian": "fy", "Irish": "ga",
    "Scots Gaelic": "gd", "Galician": "gl", "Haitian Creole": "ht", "Croatian": "hr",
    "Armenian": "hy", "Icelandic": "is", "Javanese": "jw", "Georgian": "ka", "Kazakh": "kk",
    "Kyrgyz": "ky", "Kurdish": "ku", "Latin": "la", "Luxembourgish": "lb", "Lithuanian": "lt",
    "Latvian": "lv", "Macedonian": "mk", "Mongolian": "mn", "Maltese": "mt", "Pashto": "ps",
    "Slovak": "sk", "Slovenian": "sl", "Albanian": "sq", "Serbian": "sr", "Sundanese": "su",
    "Tajik": "tg", "Uzbek": "uz", "Yiddish": "yi", "Yoruba": "yo"
}

# Tesseract Language Mapping (ISO 639-1 -> Tesseract Code)
TESS_LANG_MAP = {
    "hi": "hin", "mr": "mar", "bn": "ben", "gu": "guj", "ta": "tam", "te": "tel",
    "kn": "kan", "ml": "mal", "pa": "pan", "ur": "urd", "or": "ori", "as": "asm",
    "ne": "nep", "sa": "san", "en": "eng", "fr": "fra", "es": "spa", "de": "deu",
    "zh": "chi_sim", "ja": "jpn", "ko": "kor", "ru": "rus", "ar": "ara", "pt": "por",
    "it": "ita", "nl": "nld", "tr": "tur", "vi": "vie", "th": "tha", "id": "ind",
    "pl": "pol", "uk": "ukr", "ro": "ron", "el": "ell", "cs": "ces", "sv": "swe",
    "hu": "hun", "he": "heb", "ms": "msa", "fa": "fas", "tl": "tgl", "fi": "fin",
    "da": "dan", "no": "nor", "sw": "swa", "af": "afr", "si": "sin", "my": "mya",
    "km": "khm", "lo": "lao",

    # Extended Mapping
    "am": "amh", "az": "aze", "be": "bel", "bo": "bod", "bs": "bos", "bg": "bul",
    "ca": "cat", "ceb": "ceb", "co": "cos", "cy": "cym", "eo": "epo", "et": "est",
    "eu": "eus", "fy": "fry", "ga": "gle", "gd": "gla", "gl": "glg", "ht": "hat",
    "hr": "hrv", "hy": "hye", "is": "isl", "jw": "jav", "ka": "kat", "kk": "kaz",
    "ky": "kir", "ku": "kmr", "la": "lat", "lb": "ltz", "lt": "lit", "lv": "lav",
    "mk": "mkd", "mn": "mon", "mt": "mlt", "ps": "pus", "sk": "slk", "sl": "slv",
    "sq": "sqi", "sr": "srp", "su": "sun", "tg": "tgk", "uz": "uzb", "yi": "yid",
    "yo": "yor",

    # Missing Indian Languages Mapped to Scripts
    "mai": "hin", # Maithili -> Hindi (Devanagari)
    "sat": "sat", # Santali
    "ks": "urd",  # Kashmiri -> Urdu (Perso-Arabic)
    "gom": "mar", # Konkani -> Marathi (Devanagari)
    "sd": "snd",  # Sindhi
    "doi": "hin", # Dogri -> Hindi
    "mni": "ben", # Manipuri -> Bengali Script
    "brx": "hin", # Bodo -> Hindi
    "sa": "san",  # Sanskrit
    "bho": "hin"  # Bhojpuri -> Hindi
}

# EasyOCR Language Mapping (ISO 639-1 -> EasyOCR Code)
# EasyOCR uses standard ISO codes mostly, but Chinese is different.
EASYOCR_LANG_MAP = {
    "zh": "ch_sim", "zh-cn": "ch_sim", "zh-tw": "ch_tra",
    "cs": "cs", "da": "da", "nl": "nl", "de": "de", "en": "en", "es": "es", "fi": "fi",
    "fr": "fr", "hu": "hu", "id": "id", "it": "it", "ja": "ja", "ko": "ko", "no": "no",
    "pl": "pl", "pt": "pt", "ro": "ro", "ru": "ru", "sk": "sk", "tr": "tr", "vi": "vi",
    "ar": "ar", "bn": "bn", "hi": "hi", "mr": "mr", "ne": "ne", "ta": "ta", "te": "te",
    "th": "th", "ur": "ur", "tl": "tl", "ms": "ms", "sw": "sw", "fa": "fa", "uk": "uk",
    "sv": "sv", "el": "el", "he": "he", "si": "si", "my": "my", "km": "km", "lo": "lo",
    
    # Mappings for languages not directly supported by EasyOCR to their script equivalent
    "mai": "hi", "sat": "hi", "ks": "ur", "gom": "mr", "sd": "ur", "doi": "hi",
    "mni": "bn", "brx": "hi", "sa": "hi", "bho": "hi", "as": "bn",
    "sr": "rs_cyrillic", # Serbian
    "tg": "tjk", # Tajik
    "uz": "uz", "ug": "ug", "be": "be", "bg": "bg", "bs": "bs", "ca": "ca",
    "cy": "cy", "et": "et", "ga": "ga", "hr": "hr", "is": "is", "ku": "ku",
    "la": "la", "lt": "lt", "lv": "lv", "mk": "mk", "mt": "mt", "sq": "sq",
    "sl": "sl", "az": "az"
}

# -------------------------
# UPLOAD FOLDER
# -------------------------
UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# -------------------------
# ROOT ROUTE (Fixes 404 on homepage)
# -------------------------
@app.route("/")
def home():
    return "", 200

# -------------------------
# PING (Keep server awake)
# -------------------------
@app.route("/ping")
def ping():
    status = {"service": "running", "translation_check": "pending"}
    try:
        # Test a simple translation (Hello -> Spanish) to verify external API connectivity
        test_trans = GoogleTranslator(source='auto', target='es').translate("Hello")
        status["translation_check"] = "success"
        status["test_result"] = test_trans
    except Exception as e:
        status["translation_check"] = "failed"
        status["error"] = str(e)
    
    return jsonify(status), 200

# -------------------------
# CACHED TRANSLATION HELPER
# -------------------------
# Caches the last 500 translations to speed up repeated requests
@lru_cache(maxsize=500)
def get_cached_translation(text, target_lang):
    return GoogleTranslator(source="auto", target=target_lang).translate(text)

# -------------------------
# FILE TRANSLATE
# -------------------------
@app.route("/file_translate", methods=["POST"])
def file_translate():
    try:
        if "file" not in request.files:
            print("Error: No file part in request")
            return jsonify({"error": "No file found"}), 400

        file = request.files["file"]
        if file.filename == '':
            print("Error: No selected file")
            return jsonify({"error": "No selected file"}), 400

        target_lang = request.form.get("target_lang", "hi")
        source_lang = request.form.get("source_lang", "auto")
        text_content = ""
        filename = file.filename.lower() if file.filename else ""
        print(f"Processing file: {filename}, Content-Type: {file.content_type}")
        print(f"Target Language: {target_lang}")

        if filename.endswith(".txt") or file.content_type == "text/plain":
            text_content = file.read().decode("utf-8")

        elif filename.endswith(".docx") or "wordprocessingml" in file.content_type:
            doc = docx.Document(file)
            text_content = "\n".join([para.text for para in doc.paragraphs])

        elif filename.endswith(".pdf") or file.content_type == "application/pdf":
            pdf_reader = PyPDF2.PdfReader(file)
            for page in pdf_reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text_content += page_text + "\n"

        elif filename.endswith((".png", ".jpg", ".jpeg", ".webp")) or file.content_type.startswith("image/"):
            image = Image.open(file)
            image = ImageOps.exif_transpose(image)

            # Resize image if it is too large to prevent memory crashes (OOM)
            # Reduced to 1800px to prevent server crashes (OOM) on free tier with EasyOCR
            if image.width > 1024 or image.height > 1024:
                image.thumbnail((1024, 1024))

            # Preprocessing
            # Convert to grayscale
            image = image.convert('L')
            # Increase contrast to make text pop against background
            image = ImageEnhance.Contrast(image).enhance(2.0)
            # Autocontrast helps with low light/low quality images
            image = ImageOps.autocontrast(image)
            # Sharpening helps extract text from blurry low-quality images
            image = ImageEnhance.Sharpness(image).enhance(1.5)
            
            # --- Smart Language Detection for OCR ---
            tess_lang = "eng"      # Tesseract language string
            easyocr_langs = ['en'] # EasyOCR language list
            detected_script = None

            # 1. Perform script detection once to inform both Tesseract and EasyOCR
            try:
                osd = pytesseract.image_to_osd(image, config='--psm 0 -c min_characters_to_try=5')
                script_match = re.search(r"Script: ([a-zA-Z]+)", osd)
                if script_match:
                    detected_script = script_match.group(1).lower()
                    print(f"Auto-detected Script: {detected_script.capitalize()}")
            except Exception as e:
                print(f"Script detection (OSD) failed: {e}")

            # 2. Configure languages based on auto-detection or user's choice
            if source_lang == "auto":
                if detected_script:
                    # Map script to a primary Tesseract language
                    script_to_tess = {
                        "devanagari": "hin", "bengali": "ben", "gurmukhi": "pan", "gujarati": "guj",
                        "oriya": "ori", "tamil": "tam", "telugu": "tel", "kannada": "kan",
                        "malayalam": "mal", "han": "chi_sim", "hangul": "kor", "hiragana": "jpn",
                        "katakana": "jpn", "cyrillic": "rus", "arabic": "ara", "hebrew": "heb",
                        "thai": "tha"
                    }
                    detected_tess_lang = script_to_tess.get(detected_script)
                    if detected_tess_lang:
                        tess_lang = f"{detected_tess_lang}+eng"

                    # Map script to EasyOCR languages
                    script_to_easyocr = {
                        "devanagari": ['hi', 'mr', 'ne'], "han": ['ch_sim', 'ch_tra'], "cyrillic": ['ru', 'uk', 'bg'],
                        "arabic": ['ar', 'fa', 'ur'], "bengali": ['bn'], "tamil": ['ta'], "telugu": ['te']
                    }
                    if detected_script in script_to_easyocr:
                        easyocr_langs.extend(l for l in script_to_easyocr[detected_script] if l not in easyocr_langs)
            else:
                # Use the user-specified language
                tess_lang = TESS_LANG_MAP.get(source_lang, "eng")
                mapped_easyocr_lang = EASYOCR_LANG_MAP.get(source_lang, source_lang)
                if mapped_easyocr_lang not in easyocr_langs:
                    easyocr_langs.insert(0, mapped_easyocr_lang)
            
            print(f"Using Tesseract with lang: '{tess_lang}'")
            print(f"Using EasyOCR with langs: {easyocr_langs}")

            # Attempt 1: OCR with Tesseract
            custom_config = r'--oem 3 --psm 3'
            text_content = ""
            try:
                # Try to read text in the selected language
                text_content = pytesseract.image_to_string(image, lang=tess_lang, config=custom_config)
            except Exception as e:
                print(f"Tesseract Attempt 1 failed: {e}")

            # Attempt 2: EasyOCR (ONLY if Tesseract failed)
            # EasyOCR is heavy and can crash free servers. We only use it as a fallback.
            if not text_content.strip():
                try:
                    print(f"Tesseract failed. Attempting EasyOCR with languages: {easyocr_langs}")
                    import easyocr
                    reader = easyocr.Reader(easyocr_langs, gpu=False)
                    results = reader.readtext(image, detail=0, paragraph=True)
                    if results:
                        text_content = "\n".join(results)
                    del reader
                    del easyocr
                    gc.collect()
                except Exception as e:
                    print(f"EasyOCR failed: {e}")

            # Attempt 3: Fallback with Thresholding (Black & White)
            # This is very fast and often fixes noisy backgrounds
            if not text_content.strip():
                print("OCR Attempt 2 empty. Retrying with thresholding...")
                try:
                    # Convert to binary (black and white)
                    thresh = image.point(lambda p: 255 if p > 128 else 0)
                    # Use the determined Tesseract language for the retry
                    text_content = pytesseract.image_to_string(thresh, lang=tess_lang, config=custom_config)
                except Exception:
                    pass

        else:
            print(f"Error: Unsupported file type: {filename}")
            return jsonify({"error": f"Unsupported file type: {filename}"}), 400

        if not text_content.strip():
            print("OCR Failed: No text extracted from image.")
            if filename.endswith(".pdf"):
                return jsonify({"error": "No text found in PDF. Scanned PDFs are not supported."}), 400
            return jsonify({"error": "No text extracted"}), 400

        # Translate in chunks to avoid 5000 char limit of Google Translator
        try:
            if len(text_content) > 4500:
                chunks = [text_content[i:i+4500] for i in range(0, len(text_content), 4500)]
                translated_chunks = []
                translator = GoogleTranslator(source="auto", target=target_lang)
                for chunk in chunks:
                    translated_chunks.append(translator.translate(chunk))
                translated_text = " ".join(translated_chunks)
            else:
                translated_text = get_cached_translation(text_content, target_lang)
            
            return jsonify({"original_text": text_content, "translated_text": translated_text})
        except Exception as e:
            print(f"Translation Error: {e}")
            # FALLBACK: Return original text with a warning, instead of crashing with 500
            return jsonify({
                "original_text": text_content, 
                "translated_text": text_content, # Fallback to original text
                "warning": f"Translation failed: {str(e)}"
            }), 200

    except Exception as e:
        print(f"Critical Error in file_translate: {e}")
        return jsonify({"error": str(e)}), 500

# -------------------------
# TEXT TRANSLATE
# -------------------------
@app.route("/translate", methods=["POST"])
def translate_text():
    try:
        data = request.get_json(force=True, silent=True)
        if not data:
            print("Error: Invalid JSON or empty body")
            return jsonify({"error": "Invalid JSON or empty body"}), 400

        text = data.get("text", "").strip()
        target_lang = data.get("target_lang", "hi")

        if not text:
            print("Error: Text is required but missing")
            return jsonify({"error": "Text is required"}), 400
        if target_lang not in lang_codes.values():
            print(f"Error: Unsupported target language '{target_lang}'")
            return jsonify({"error": f"Target language '{target_lang}' not supported"}), 400

        translated_text = get_cached_translation(text, target_lang)
        return jsonify({"translated_text": translated_text})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# -------------------------
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    print(f"Server running on port {port}")
    app.run(host="0.0.0.0", port=port, threaded=True)
