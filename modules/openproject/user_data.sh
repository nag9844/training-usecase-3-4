#!/bin/bash
set -e

# Update system packages
apt-get update -y
apt-get upgrade -y

# Install prerequisites
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common

# Add Docker's GPG key and repository
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker and add ubuntu user to docker group
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Install legacy Docker Compose CLI (optional)
curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Create project directory
mkdir -p /opt/openproject

# Create docker-compose.yml for OpenProject
cat > /opt/openproject/docker-compose.yml << 'EOF'
version: '3'

services:
  db:
    image: postgres:13
    restart: always
    environment:
      POSTGRES_USER: openproject
      POSTGRES_PASSWORD: openproject
      POSTGRES_DB: openproject
    volumes:
      - postgres-data:/var/lib/postgresql/data

  openproject:
    image: openproject/community:13.0
    restart: always
    depends_on:
      - db
    environment:
      DATABASE_URL: postgres://openproject:openproject@db:5432/openproject
      SECRET_KEY_BASE: secret
      RAILS_MIN_THREADS: 4
      RAILS_MAX_THREADS: 16
      USE_PUMA: "true"
    volumes:
      - openproject-data:/var/openproject/assets
    ports:
      - "80:80"

volumes:
  postgres-data:
  openproject-data:
EOF

# Start OpenProject
cd /opt/openproject
docker-compose up -d

echo "Docker and OpenProject installation completed on Ubuntu."
