FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# Set working directory
WORKDIR /app

# Install system dependencies for MySQL + Gunicorn
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    libnss3 \
    libdbus-glib-1-2 \
    libgtk-3-0 \
    libx11-xcb1 \
    libasound2 \
    libxtst6 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

EXPOSE 8000

# Correct Gunicorn CMD
CMD ["uvicorn", "nagp_kube_devops_demo.asgi:application", "--host", "0.0.0.0", "--port", "8000"]
