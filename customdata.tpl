#!/bin/bash
# Update the system and install necessary dependencies
echo "Updating the system..."
sudo apt update -y
sudo apt upgrade -y

# Install Docker if it's not already installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    sudo apt-get install -y docker.io
else
    echo "Docker is already installed."
fi

# Start Docker service and enable it to start on boot
echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Check if Docker is running correctly
echo "Checking Docker version..."
docker --version

# Print Docker service status
echo "Checking Docker service status..."
sudo systemctl status docker --no-pager

