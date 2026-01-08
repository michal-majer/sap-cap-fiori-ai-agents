---
name: sap-cap-deployment
description: "Deploy SAP CAP + Fiori applications to SAP BTP Cloud Foundry. Covers MTA build, XSUAA, HANA Cloud, AppRouter, and CI/CD."
alwaysApply: false
---

# SAP CAP Deployment Guide

Deploy your CAP + Fiori application to SAP BTP Cloud Foundry (trial or production).

---

## Quick Deploy Recipe

```bash
# Step 1: Install tools (one-time)
npm install -g mbt
cf install-plugin multiapps

# Step 2: Add cloud configuration
cds add mta
cds add xsuaa
cds add hana

# Step 3: Build MTA archive
mbt build

# Step 4: Login and deploy
cf login -a <api-endpoint>
cf deploy mta_archives/<app>_1.0.0.mtar

# Step 5: Verify
cf apps
cf services
```

---

## Prerequisites

### Required Tools

```bash
# Cloud Foundry CLI
brew install cloudfoundry/tap/cf-cli@8

# MTA Build Tool
npm install -g mbt

# Multiapps Plugin
cf install-plugin multiapps

# Verify installation
cf --version
mbt --version
```

### BTP Account Setup

1. **Trial Account**: [SAP BTP Trial](https://account.hanatrial.ondemand.com/)
   - Free, 30-day reset cycle
   - Limited resources (4GB memory, 30GB HANA)

2. **Production Account**: Enterprise contract required
   - Region-specific API endpoints
   - Full entitlements

### API Endpoints

| Region | Trial | Production |
|--------|-------|------------|
| US East | `api.cf.us10-001.hana.ondemand.com` | `api.cf.us10.hana.ondemand.com` |
| EU Central | `api.cf.eu10-004.hana.ondemand.com` | `api.cf.eu10.hana.ondemand.com` |
| AP Sydney | - | `api.cf.ap10.hana.ondemand.com` |

---

## Step-by-Step Deployment

### Step 1: Add MTA Configuration

```bash
cds add mta
```

This creates `mta.yaml` in your project root:

```yaml
_schema-version: "3.2"
ID: my-cap-app
version: 1.0.0

parameters:
  enable-parallel-deployments: true

build-parameters:
  before-all:
    - builder: custom
      commands:
        - npm ci
        - npx cds build --production

modules:
  # CAP Backend Service
  - name: my-cap-app-srv
    type: nodejs
    path: gen/srv
    parameters:
      buildpack: nodejs_buildpack
      memory: 256M
    requires:
      - name: my-cap-app-auth
      - name: my-cap-app-db
    provides:
      - name: srv-api
        properties:
          srv-url: ${default-url}

  # HANA Database Deployer
  - name: my-cap-app-db-deployer
    type: hdb
    path: gen/db
    parameters:
      buildpack: nodejs_buildpack
    requires:
      - name: my-cap-app-db

  # AppRouter (UI)
  - name: my-cap-app-app
    type: approuter.nodejs
    path: app/router
    parameters:
      keep-existing-routes: true
      disk-quota: 256M
      memory: 256M
    requires:
      - name: srv-api
        group: destinations
        properties:
          name: srv
          url: ~{srv-url}
          forwardAuthToken: true
      - name: my-cap-app-auth

resources:
  # XSUAA Service
  - name: my-cap-app-auth
    type: org.cloudfoundry.managed-service
    parameters:
      service: xsuaa
      service-plan: application
      path: ./xs-security.json
      config:
        xsappname: my-cap-app-${org}-${space}
        tenant-mode: dedicated

  # HANA Cloud
  - name: my-cap-app-db
    type: com.sap.xs.hdi-container
    parameters:
      service: hana
      service-plan: hdi-shared
```

### Step 2: Add XSUAA Configuration

```bash
cds add xsuaa
```

This creates `xs-security.json`:

```json
{
  "xsappname": "my-cap-app",
  "tenant-mode": "dedicated",
  "scopes": [
    {
      "name": "$XSAPPNAME.admin",
      "description": "Administrator"
    },
    {
      "name": "$XSAPPNAME.user",
      "description": "Regular User"
    }
  ],
  "attributes": [],
  "role-templates": [
    {
      "name": "Admin",
      "description": "Administrator Role",
      "scope-references": ["$XSAPPNAME.admin"]
    },
    {
      "name": "User",
      "description": "User Role",
      "scope-references": ["$XSAPPNAME.user"]
    }
  ],
  "role-collections": [
    {
      "name": "my-cap-app-admin",
      "description": "Admin Role Collection",
      "role-template-references": ["$XSAPPNAME.Admin"]
    },
    {
      "name": "my-cap-app-user",
      "description": "User Role Collection",
      "role-template-references": ["$XSAPPNAME.User"]
    }
  ]
}
```

**Match with CDS authorization:**

```cds
// srv/access-control.cds
service AdminService @(requires: 'admin') { ... }
service CatalogService @(requires: 'authenticated-user') { ... }
```

### Step 3: Add HANA Configuration

```bash
cds add hana
```

Updates `package.json`:

```json
{
  "cds": {
    "requires": {
      "db": {
        "kind": "hana",
        "[development]": {
          "kind": "sqlite"
        }
      }
    }
  }
}
```

### Step 4: Create AppRouter

Create `app/router/package.json`:

```json
{
  "name": "my-cap-app-router",
  "dependencies": {
    "@sap/approuter": "^16"
  },
  "scripts": {
    "start": "node node_modules/@sap/approuter/approuter.js"
  }
}
```

Create `app/router/xs-app.json`:

```json
{
  "welcomeFile": "/index.html",
  "authenticationMethod": "route",
  "routes": [
    {
      "source": "^/odata/v4/(.*)$",
      "target": "/odata/v4/$1",
      "destination": "srv",
      "authenticationType": "xsuaa",
      "csrfProtection": true
    },
    {
      "source": "^/(.*)$",
      "target": "$1",
      "service": "html5-apps-repo-rt",
      "authenticationType": "xsuaa"
    }
  ]
}
```

### Step 5: Build MTA Archive

```bash
mbt build
```

Output: `mta_archives/my-cap-app_1.0.0.mtar`

### Step 6: Deploy to Cloud Foundry

```bash
# Login
cf login -a api.cf.us10-001.hana.ondemand.com

# Deploy
cf deploy mta_archives/my-cap-app_1.0.0.mtar

# Or with specific org/space
cf deploy mta_archives/my-cap-app_1.0.0.mtar -o myorg -s dev
```

### Step 7: Assign Role Collections

1. Open SAP BTP Cockpit
2. Navigate to **Security > Users**
3. Select your user
4. Click **Assign Role Collection**
5. Add `my-cap-app-admin` or `my-cap-app-user`

---

## Trial vs Production

| Aspect | Trial | Production |
|--------|-------|------------|
| **API Endpoint** | `api.cf.us10-001.hana.ondemand.com` | Region-specific |
| **HANA Cloud** | Shared, 30GB limit | Dedicated, configurable |
| **App Runtime** | 4GB memory limit | Based on entitlements |
| **Custom Domains** | Not available | Supported |
| **Multi-Tenancy** | Not recommended | Full SaaS support |
| **SLA** | None | 99.9%+ |
| **Reset Cycle** | 30 days | None |

### Production-Only Features

- Custom domains with SSL certificates
- Multi-tenant SaaS applications
- Destination service with principal propagation
- SAP Cloud Connector integration
- Audit logging
- SAP Cloud ALM integration

---

## Multi-Tenancy (Production Only)

For SaaS applications, update `xs-security.json`:

```json
{
  "xsappname": "my-saas-app",
  "tenant-mode": "shared",
  "scopes": [...],
  "role-templates": [...]
}
```

Update `mta.yaml` to include MTX sidecar:

```yaml
modules:
  - name: my-saas-app-mtx
    type: nodejs
    path: gen/mtx/sidecar
    requires:
      - name: my-saas-app-registry
      - name: my-saas-app-db

resources:
  - name: my-saas-app-registry
    type: org.cloudfoundry.managed-service
    parameters:
      service: saas-registry
      service-plan: application
```

---

## CI/CD Pipeline

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to SAP BTP

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  CF_API: ${{ secrets.CF_API }}
  CF_ORG: ${{ secrets.CF_ORG }}
  CF_SPACE: ${{ secrets.CF_SPACE }}

jobs:
  build-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install MBT
        run: npm install -g mbt

      - name: Build MTA
        run: mbt build

      - name: Install CF CLI
        run: |
          wget -q -O cf-cli.deb "https://packages.cloudfoundry.org/stable?release=debian64&version=v8"
          sudo dpkg -i cf-cli.deb
          cf install-plugin multiapps -f

      - name: Deploy to BTP
        run: |
          cf login -a $CF_API -u ${{ secrets.CF_USER }} -p ${{ secrets.CF_PASSWORD }} -o $CF_ORG -s $CF_SPACE
          cf deploy mta_archives/*.mtar -f
```

### Required Secrets

| Secret | Description |
|--------|-------------|
| `CF_API` | CF API endpoint |
| `CF_ORG` | Cloud Foundry org |
| `CF_SPACE` | Cloud Foundry space |
| `CF_USER` | BTP user email |
| `CF_PASSWORD` | BTP password or API key |

---

## Useful Commands

```bash
# Check deployed apps
cf apps

# Check services
cf services

# View logs
cf logs my-cap-app-srv --recent

# Stream logs
cf logs my-cap-app-srv

# Scale app
cf scale my-cap-app-srv -m 512M -i 2

# Restart app
cf restart my-cap-app-srv

# Undeploy
cf undeploy my-cap-app --delete-services

# Check MTA operations
cf mta-ops
```

---

## Troubleshooting

### Common Errors

#### 1. "Service broker error: hana service not available"

**Cause:** HANA Cloud not provisioned in your space.

**Fix:**
```bash
# Check available services
cf marketplace

# Create HANA Cloud instance manually
cf create-service hana hdi-shared my-cap-app-db
```

#### 2. "Insufficient resources"

**Cause:** Trial account memory limit exceeded.

**Fix:** Reduce memory in `mta.yaml`:
```yaml
parameters:
  memory: 128M  # Reduce from 256M
```

#### 3. "XSUAA: Invalid redirect URI"

**Cause:** OAuth callback URL not configured.

**Fix:** Add to `xs-security.json`:
```json
{
  "oauth2-configuration": {
    "redirect-uris": [
      "https://*.cfapps.us10-001.hana.ondemand.com/**"
    ]
  }
}
```

#### 4. "HDI container creation failed"

**Cause:** HANA Cloud instance not running.

**Fix:**
1. Open BTP Cockpit
2. Go to **SAP HANA Cloud**
3. Ensure instance is running (auto-stops after inactivity on trial)

#### 5. "Authentication required" after deployment

**Cause:** User not assigned to role collection.

**Fix:**
1. BTP Cockpit > Security > Users
2. Select user
3. Assign Role Collection

#### 6. "Route already exists"

**Cause:** Previous deployment left orphaned routes.

**Fix:**
```bash
cf delete-orphaned-routes
```

---

## Environment-Specific Configuration

### package.json profiles

```json
{
  "cds": {
    "requires": {
      "db": {
        "kind": "hana",
        "[development]": {
          "kind": "sqlite",
          "credentials": { "url": "db.sqlite" }
        },
        "[hybrid]": {
          "kind": "hana"
        }
      },
      "auth": {
        "kind": "xsuaa",
        "[development]": {
          "kind": "mocked",
          "users": {
            "admin": { "roles": ["admin"] }
          }
        },
        "[hybrid]": {
          "kind": "xsuaa"
        }
      }
    }
  }
}
```

### Hybrid Testing

Test with real HANA + XSUAA locally:

```bash
# Bind to cloud services
cds bind -2 my-cap-app-db
cds bind -2 my-cap-app-auth

# Run with hybrid profile
cds watch --profile hybrid
```

---

## Checklist Before Deployment

- [ ] All tests pass locally (`cds watch`)
- [ ] `mta.yaml` has correct module names
- [ ] `xs-security.json` scopes match CDS `@requires`
- [ ] AppRouter routes match service paths
- [ ] HANA Cloud instance is running
- [ ] Role collections defined for all user types
- [ ] Memory limits appropriate for trial (if applicable)
- [ ] CI/CD secrets configured (if using)

---

## Next Steps After Deployment

1. **Assign users** to role collections in BTP Cockpit
2. **Configure custom domain** (production only)
3. **Set up monitoring** with SAP Cloud ALM
4. **Enable logging** with SAP Application Logging
5. **Configure destinations** for external services
