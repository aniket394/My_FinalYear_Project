# Use a lightweight Python base image
FROM python:3.10-slim

# Enable unbuffered logging to see errors in Render logs immediately
ENV PYTHONUNBUFFERED=1

# 1. Install system dependencies (Tesseract OCR)
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    tesseract-ocr-eng \
    tesseract-ocr-hin \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# 2. Copy requirements and install Python dependencies
COPY requirements.txt .
# Explicitly install gunicorn to ensure it exists
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# 3. Copy the rest of the application code
COPY . .

# 4. Run the download script to fetch high-accuracy language models
RUN python download_tessdata.py

# Set the environment variable so Tesseract knows where the downloaded models are
ENV TESSDATA_PREFIX=/app/tessdata

# 5. Start the application using Gunicorn
# Render automatically sets the PORT environment variable
# Use 'sh -c' to ensure variable expansion works correctly
# Use 1 worker and 8 threads to save memory on Render Free Tier
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:$PORT --workers 1 --threads 8 --timeout 120 lib.app:app"]