# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Install system dependencies (Tesseract OCR)
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
# We copy app.py from the lib folder to the root of the container app
COPY lib/app.py .

# Expose the port the app runs on
EXPOSE 5000

# Run the application using Gunicorn
# "app:app" means: look in module "app" (app.py) for the variable "app" (Flask instance)
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]