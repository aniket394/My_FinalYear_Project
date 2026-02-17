# Use a lightweight Python base image
FROM python:3.10-slim

# Enable unbuffered logging to see errors in Render logs immediately
ENV PYTHONUNBUFFERED=1

# Set the working directory inside the container
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Start the application using Gunicorn
# Use 1 worker and 8 threads to save memory on Render Free Tier
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:$PORT --workers 1 --threads 8 --timeout 120 lib.app:app"]