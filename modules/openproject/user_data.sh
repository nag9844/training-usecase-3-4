#!/bin/bash
set -e

# Update system packages
yum update -y

# Install Docker
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
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

# Configure Nginx for proxy if we want to add it later
echo "Docker installation and OpenProject setup completed."