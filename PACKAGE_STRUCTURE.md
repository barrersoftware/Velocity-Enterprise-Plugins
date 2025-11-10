# Velocity Enterprise Plugin Package Structure

## Package Types

### 1. **Code Plugins** (Frontend Only)
Simple UI plugins with no backend service required.

```
code-plugins/
└── my-plugin/
    ├── manifest.json
    ├── client.js
    ├── view.html
    └── package.json
```

### 2. **App Packages** (Full Stack)
Complete applications with frontend plugins + backend services.

```
app-packages/
└── keycloak-sso/
    ├── manifest.json (package manifest)
    ├── plugins/
    │   ├── user-management/
    │   │   ├── manifest.json
    │   │   ├── client.js
    │   │   └── view.html
    │   ├── role-management/
    │   │   ├── manifest.json
    │   │   ├── client.js
    │   │   └── view.html
    │   └── permission-management/
    │       ├── manifest.json
    │       ├── client.js
    │       └── view.html
    ├── backend/
    │   ├── docker-compose.yml
    │   ├── install-native.sh
    │   └── config/
    └── installer.js (auto-setup script)
```

## Package Manifest Schema

### Code Plugin Manifest
```json
{
  "id": "my-plugin",
  "type": "code",
  "name": "My Plugin",
  "version": "1.0.0",
  "description": "Does something cool",
  "author": "Your Name",
  "icon": "🔧",
  "downloadUrl": "https://raw.githubusercontent.com/.../my-plugin.zip"
}
```

### App Package Manifest
```json
{
  "id": "keycloak-sso",
  "type": "package",
  "name": "Keycloak SSO",
  "version": "1.0.0",
  "description": "Complete SSO solution with user/role/permission management",
  "author": "Barrer Software",
  "icon": "🔐",
  "category": "Authentication",
  "plugins": [
    {
      "id": "user-management",
      "name": "User Manager",
      "icon": "👤"
    },
    {
      "id": "role-management",
      "name": "Role Manager",
      "icon": "👥"
    },
    {
      "id": "permission-management",
      "name": "Permission Manager",
      "icon": "🛡️"
    }
  ],
  "backend": {
    "type": "keycloak",
    "docker": true,
    "native": true,
    "ports": [8080, 8443],
    "envVars": {
      "KEYCLOAK_ADMIN": "admin",
      "KEYCLOAK_ADMIN_PASSWORD": "auto-generated"
    }
  },
  "downloadUrl": "https://raw.githubusercontent.com/.../keycloak-sso.zip",
  "installerScript": "installer.js"
}
```

## Installation Flow

### Code Plugin
1. Download zip
2. Extract to `/plugins/plugin-id/`
3. Register in plugin manager
4. Done ✅

### App Package
1. Download package zip
2. Extract plugins to `/plugins/`
3. Extract backend to `/services/package-id/`
4. Run `installer.js`:
   - Detect Docker/Native preference
   - Auto-generate credentials
   - Start backend service
   - Configure plugin ↔ backend connection
   - Register all plugins in manager
5. Done ✅

## Store Structure

```
Velocity-Enterprise-Plugins/
├── manifest.json (store index)
├── code-plugins/
│   ├── custom-dashboard/
│   ├── analytics/
│   └── ...
└── app-packages/
    ├── keycloak-sso/
    ├── gitlab/
    ├── mailcow/
    ├── headscale-vpn/
    └── ...
```
