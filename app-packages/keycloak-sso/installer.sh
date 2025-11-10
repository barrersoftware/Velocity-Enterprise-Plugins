#!/bin/bash
# Keycloak SSO Package Installer
# Auto-installs Keycloak service (Docker or Native) + frontend plugins

set -e

PACKAGE_NAME="Keycloak SSO"
PACKAGE_ID="keycloak-sso"
INSTALL_DIR="/opt/velocity/services/$PACKAGE_ID"
PLUGIN_DIR="/opt/velocity/plugins"
CONFIG_FILE="$INSTALL_DIR/config.json"

echo "🔐 Installing $PACKAGE_NAME..."

# Generate secure random passwords
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-32
}

KEYCLOAK_ADMIN_PASSWORD=$(generate_password)
KC_DB_PASSWORD=$(generate_password)

# Detect installation method
if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
    INSTALL_METHOD="docker"
    echo "✅ Docker detected - using containerized deployment"
else
    INSTALL_METHOD="native"
    echo "⚠️  Docker not found - using native installation"
fi

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$PLUGIN_DIR"

if [ "$INSTALL_METHOD" = "docker" ]; then
    # Docker Installation
    echo "📦 Setting up Docker Compose..."
    
    # Create .env file
    cat > "$INSTALL_DIR/.env" << EOF
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=$KEYCLOAK_ADMIN_PASSWORD
KC_DB_PASSWORD=$KC_DB_PASSWORD
EOF
    
    # Copy docker-compose.yml
    cp backend/docker-compose.yml "$INSTALL_DIR/"
    
    # Start services
    cd "$INSTALL_DIR"
    docker-compose up -d
    
    echo "⏳ Waiting for Keycloak to be ready..."
    timeout=300
    elapsed=0
    while ! curl -sf http://localhost:8080/health/ready > /dev/null; do
        if [ $elapsed -ge $timeout ]; then
            echo "❌ Keycloak failed to start within ${timeout}s"
            exit 1
        fi
        sleep 5
        elapsed=$((elapsed + 5))
        echo "  ... still waiting ($elapsed/${timeout}s)"
    done
    
    SERVICE_URL="http://localhost:8080"
    
else
    # Native Installation
    echo "📦 Installing Keycloak natively..."
    bash backend/install-native.sh "$KEYCLOAK_ADMIN_PASSWORD" "$KC_DB_PASSWORD"
    SERVICE_URL="http://localhost:8080"
fi

# Install frontend plugins
echo "🔌 Installing frontend plugins..."
for plugin_dir in plugins/*/; do
    plugin_name=$(basename "$plugin_dir")
    echo "  - Installing $plugin_name..."
    cp -r "$plugin_dir" "$PLUGIN_DIR/"
done

# Save configuration
cat > "$CONFIG_FILE" << EOF
{
  "packageId": "$PACKAGE_ID",
  "packageName": "$PACKAGE_NAME",
  "version": "1.0.0",
  "installMethod": "$INSTALL_METHOD",
  "serviceUrl": "$SERVICE_URL",
  "adminUsername": "admin",
  "adminPassword": "$KEYCLOAK_ADMIN_PASSWORD",
  "installedAt": "$(date -Iseconds)",
  "plugins": [
    "user-management",
    "role-management",
    "permission-management"
  ],
  "status": "running"
}
EOF

# Output credentials
echo ""
echo "✅ $PACKAGE_NAME installed successfully!"
echo ""
echo "🔐 Admin Credentials:"
echo "   URL: $SERVICE_URL"
echo "   Username: admin"
echo "   Password: $KEYCLOAK_ADMIN_PASSWORD"
echo ""
echo "📝 Configuration saved to: $CONFIG_FILE"
echo ""
echo "🔌 Frontend plugins installed:"
echo "   - User Manager"
echo "   - Role Manager"
echo "   - Permission Manager"
echo ""
echo "🚀 Keycloak is ready! Refresh the panel to see the new plugins."
