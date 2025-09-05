FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Petals
RUN pip install git+https://github.com/bigscience-workshop/petals

# Create entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expose default DHT port
EXPOSE 31337

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
