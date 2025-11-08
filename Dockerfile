# Use a stable, supported base image
FROM python:3.11-slim-bullseye

# set work directory
WORKDIR /app

# Install system dependencies for psycopg2 and DNS utilities
RUN apt-get update && apt-get install --no-install-recommends -y \
      dnsutils \
      libpq-dev \
      python3-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Set environment variables (correct syntax)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install --no-install-recommends -y \
      gcc \
      libpq-dev \
      python3-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install pip and Python dependencies
RUN python -m pip install --no-cache-dir pip==25.3
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# copy project
COPY . /app/

# expose app port
EXPOSE 8000

# run migrations
RUN python3 /app/manage.py migrate

# set working directory for pygoat
WORKDIR /app/pygoat/

# start gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers","6", "pygoat.wsgi"]
