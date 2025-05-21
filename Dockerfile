FROM python:3.9-slim

# Create a non-root user to run the application
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY app/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ .

# Set environment variables
ENV PORT=8080
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Expose the port the app runs on
EXPOSE 8080

# Switch to non-root user
USER appuser

# Use gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
