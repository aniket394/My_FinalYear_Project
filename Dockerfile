# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Install system dependencies (Tesseract OCR)
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-all \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Run the application using Gunicorn, binding to the PORT environment variable
# We use --chdir lib because your app.py is inside the lib/ folder
CMD gunicorn --chdir lib --bind 0.0.0.0:${PORT:-5000} --workers 1 --threads 8 --timeout 120 app:app