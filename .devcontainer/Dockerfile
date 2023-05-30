FROM python:3.9

# Install required packages
RUN apt-get update && \
    apt-get -y install sqlite3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /workspace

# Copy the project files into the container
COPY . /workspace

# Install Python dependencies
RUN pip install -r requirements.txt

# Expose the default RStudio port
EXPOSE 8787
