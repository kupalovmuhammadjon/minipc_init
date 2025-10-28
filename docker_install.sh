#!/bin/bash

# Docker Installation Script for Ubuntu
# This script installs Docker CE and Docker Compose plugin

set -e  # Exit on any error

echo "Starting Docker installation..."

# Update package index
echo "Updating package index..."
sudo apt update

# Install prerequisite packages
echo "Installing prerequisite packages..."
sudo apt install -y ca-certificates curl gnupg

# Create directory for Docker's GPG key
echo "Setting up Docker's GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release; echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index with Docker packages
echo "Updating package index with Docker packages..."
sudo apt update

# Install Docker Engine, CLI, containerd, and Docker Compose plugin
echo "Installing Docker packages..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add current user to docker group (optional but recommended)
echo "Adding current user to docker group..."
sudo usermod -aG docker $USER

echo "Docker installation completed successfully!"
echo ""
echo "IMPORTANT: You may need to log out and back in (or restart) for group changes to take effect."
echo "After that, you can test the installation with: docker run --rm hello-world"
echo ""
echo "To apply group changes immediately in this session, run: newgrp docker"