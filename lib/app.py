# Deployed URL: https://my-finalyear-project.onrender.com
from flask import Flask, request, jsonify
from flask_cors import CORS
from deep_translator import GoogleTranslator
import os, docx, PyPDF2
from functools import lru_cache

# Try importing Google Cloud Vision (Install via: pip install google-cloud-vision)
try:
    from google.cloud import vision
    VISION_API_AVAILABLE = True
except ImportError:
    VISION_API_AVAILABLE = False

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

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

        # IMAGE HANDLING (For languages not supported by ML Kit)
        elif filename.endswith((".jpg", ".jpeg", ".png", ".webp")):
            if not VISION_API_AVAILABLE:
                print("Error: google-cloud-vision library not installed.")
                return jsonify({"error": "Server OCR not configured. Install google-cloud-vision."}), 500
            
            try:
                client = vision.ImageAnnotatorClient()
                content = file.read()
                image = vision.Image(content=content)
                response = client.text_detection(image=image)
                if response.text_annotations:
                    text_content = response.text_annotations[0].description
            except Exception as e:
                print(f"Google Cloud Vision Error: {e}")
                return jsonify({"error": f"Cloud OCR failed: {str(e)}"}), 500

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
