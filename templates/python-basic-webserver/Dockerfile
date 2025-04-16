# filename: templates/python-basic-webserver/Dockerfile
# Docker image for the Python Flask web application

# Use Python 3.11 slim image as the base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the port that the app runs on
EXPOSE 3000

# Command to run the application
CMD ["python", "app/app.py"]