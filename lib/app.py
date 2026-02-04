from flask import Flask, request, jsonify
from flask_cors import CORS
from deep_translator import GoogleTranslator
import os, docx, PyPDF2
from PIL import Image, ImageOps, ImageEnhance
import pytesseract, shutil

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# -------------------------
# TESSERACT CONFIGURATION
# -------------------------
if shutil.which("tesseract"):
    print("Tesseract found in system PATH.")
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
}

# -------------------------
# UPLOAD FOLDER
# -------------------------
UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# -------------------------
# PING (Keep server awake)
# -------------------------
@app.route("/ping")
def ping():
    return "OK", 200

# -------------------------
# FILE TRANSLATE
# -------------------------
@app.route("/file_translate", methods=["POST"])
def file_translate():
    try:
        if "file" not in request.files:
            return jsonify({"error": "No file found"}), 400

        file = request.files["file"]
        target_lang = request.form.get("target_lang", "hi")
        text_content = ""

        if file.filename.lower().endswith(".txt"):
            text_content = file.read().decode("utf-8")

        elif file.filename.lower().endswith(".docx"):
            doc = docx.Document(file)
            text_content = "\n".join([para.text for para in doc.paragraphs])

        elif file.filename.lower().endswith(".pdf"):
            pdf_reader = PyPDF2.PdfReader(file)
            for page in pdf_reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text_content += page_text + "\n"

        elif file.filename.lower().endswith((".png", ".jpg", ".jpeg")):
            image = Image.open(file)
            image = ImageOps.exif_transpose(image)
            image = ImageOps.grayscale(image)
            image = ImageEnhance.Contrast(image).enhance(2.0)
            text_content = pytesseract.image_to_string(image)

        else:
            return jsonify({"error": "Unsupported file type"}), 400

        if not text_content.strip():
            return jsonify({"error": "No text extracted"}), 400

        translated_text = GoogleTranslator(source="auto", target=target_lang).translate(text_content)
        return jsonify({"original_text": text_content, "translated_text": translated_text})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# -------------------------
# TEXT TRANSLATE
# -------------------------
@app.route("/translate", methods=["POST"])
def translate_text():
    try:
        data = request.get_json(force=True)
        text = data.get("text", "").strip()
        target_lang = data.get("target_lang", "hi")

        if not text:
            return jsonify({"error": "Text is required"}), 400
        if target_lang not in lang_codes.values():
            return jsonify({"error": f"Target language '{target_lang}' not supported"}), 400

        translated_text = GoogleTranslator(source="auto", target=target_lang).translate(text)
        return jsonify({"translated_text": translated_text})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# -------------------------
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    print(f"Server running on port {port}")
    app.run(host="0.0.0.0", port=port, threaded=True)
