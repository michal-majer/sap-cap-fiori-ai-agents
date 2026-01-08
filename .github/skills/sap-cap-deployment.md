---
name: sap-cap-deployment
description: Expert in deploying SAP CAP applications to SAP BTP Cloud Foundry
---

# SAP CAP Deployment Skill

This skill provides guidance for deploying SAP CAP applications to SAP Business Technology Platform (BTP) Cloud Foundry environment.

## When to Use

- Deploying CAP applications to SAP BTP Cloud Foundry
- Setting up MTA (Multi-Target Application) configuration
- Configuring XSUAA (authentication service)
- Connecting to SAP HANA Cloud
- Setting up AppRouter for multi-app deployments
- Troubleshooting deployment issues
- Configuring CI/CD pipelines for BTP deployment

## How to Invoke

From your IDE (VSCode/Cursor with Claude Code extension):

```
Help me deploy my CAP app to SAP BTP Cloud Foundry
```

```
Set up MTA configuration with XSUAA and HANA Cloud
```

```
Troubleshoot deployment error: service binding failed
```

## Quick Deploy Recipe (7 Steps)

1. **Install tools**: `npm install -g mbt` + `cf install-plugin multiapps`
2. **Add MTA**: `cds add mta`
3. **Add XSUAA**: `cds add xsuaa`
4. **Add HANA**: `cds add hana`
5. **Build MTA**: `mbt build`
6. **Login to CF**: `cf login -a <api-endpoint>`
7. **Deploy**: `cf deploy mta_archives/<app>.mtar`

## Prerequisites

- **SAP BTP Account** (trial or production)
- **Cloud Foundry CLI** installed
- **MTA Build Tool** (`mbt`)
- **MultiApps CF Plugin**
- **HANA Cloud** instance (optional, can use SQLite in dev)

## Key Configuration Files

- **mta.yaml** - Multi-target application descriptor
- **xs-security.json** - XSUAA security configuration (roles, scopes)
- **package.json** - Build scripts and dependencies
- **.cdsrc.json** - Production profiles

## Common Issues & Solutions

- **Service binding errors**: Check service names in mta.yaml match BTP
- **Authentication failures**: Verify XSUAA configuration and role assignments
- **Build failures**: Check Node.js version compatibility
- **Memory issues**: Increase memory in mta.yaml resources
- **HANA connection errors**: Verify HANA Cloud instance is running

## BTP Regions & API Endpoints

- **US10 (trial)**: https://api.cf.us10.hana.ondemand.com
- **EU10**: https://api.cf.eu10.hana.ondemand.com
- **AP21**: https://api.cf.ap21.hana.ondemand.com

## Full Documentation

See [../../.ai/sap-cap-deployment.md](../../.ai/sap-cap-deployment.md) for:
- Complete deployment guide (610 lines)
- MTA configuration examples
- XSUAA setup patterns
- HANA Cloud integration
- CI/CD pipeline examples
- Troubleshooting guide

## Example Usage

**Initial deployment:**
```
Walk me through deploying my first CAP app to BTP trial account
```

**Production setup:**
```
Configure production deployment with HANA Cloud and custom domain
```

**CI/CD:**
```
Set up GitHub Actions to automatically deploy to BTP on merge to main
```

**Troubleshooting:**
```
My deployment fails with "xs-security.json not found" - how do I fix this?
```
