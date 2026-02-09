# Use a lightweight Python base image
FROM python:3.10-slim

# 1. Install system dependencies (Tesseract OCR)
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# 2. Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copy the rest of the application code
COPY . .

# 4. Run the download script to fetch high-accuracy language models
RUN python download_tessdata.py

# Set the environment variable so Tesseract knows where the downloaded models are
ENV TESSDATA_PREFIX=/app/tessdata

# 5. Start the application using Gunicorn
# Render automatically sets the PORT environment variable
CMD gunicorn --bind 0.0.0.0:$PORT lib.app:app