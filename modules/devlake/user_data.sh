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
mkdir -p /opt/devlake

# Create docker-compose.yml for DevLake
cat > /opt/devlake/docker-compose.yml << 'EOF'
version: "3"

services:
  mysql:
    image: mysql:8
    volumes:
      - mysql-storage:/var/lib/mysql
    restart: always
    ports:
      - "127.0.0.1:3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: admin
      MYSQL_DATABASE: lake
      MYSQL_USER: merico
      MYSQL_PASSWORD: merico

  postgres:
    image: postgres:14.2-alpine
    volumes:
      - grafana-storage:/var/lib/postgresql/data
    restart: always
    ports:
      - "127.0.0.1:5432:5432"
    environment:
      POSTGRES_DB: grafana
      POSTGRES_USER: merico
      POSTGRES_PASSWORD: merico

  grafana:
    image: apache/devlake-dashboard:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana-storage:/var/lib/grafana
    environment:
      GF_SERVER_ROOT_URL: "http://localhost:4000/grafana"
      GF_SERVER_SERVE_FROM_SUB_PATH: "true"
      GF_USERS_ALLOW_SIGN_UP: "false"
      GF_USERS_ALLOW_ORG_CREATE: "false"
      GF_AUTH_ANONYMOUS_ENABLED: "true"
      GF_AUTH_ANONYMOUS_ORG_ROLE: "Admin"
      GF_INSTALL_PLUGINS: "grafana-piechart-panel"
      GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS: "merico-dashboards"
      GF_DASHBOARDS_JSON_ENABLED: "true"
      GF_DASHBOARDS_JSON_PATH: "/var/lib/grafana/dashboards"
      GF_SECURITY_ADMIN_USER: "admin"
      GF_SECURITY_ADMIN_PASSWORD: "admin"
    depends_on:
      - postgres

  devlake:
    image: apache/devlake:v0.20.0
    ports:
      - "80:8080"
    restart: always
    volumes:
      - devlake-storage:/app/config
    environment:
      MYSQL_URL: mysql:3306
      MYSQL_DATABASE: lake
      MYSQL_USER: merico
      MYSQL_PASSWORD: merico
    depends_on:
      - mysql

volumes:
  mysql-storage: {}
  grafana-storage: {}
  devlake-storage: {}
EOF

# Start DevLake
cd /opt/devlake
docker-compose up -d

echo "Docker installation and DevLake setup completed."