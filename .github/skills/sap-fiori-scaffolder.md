---
name: sap-fiori-scaffolder
description: Expert in generating SAP Fiori Elements applications programmatically using @sap-ux tools
---

# SAP Fiori Scaffolder Skill

This skill helps generate Fiori Elements applications programmatically using `@sap-ux/fiori-elements-writer` and related SAP tooling.

## When to Use

- Generating Fiori apps programmatically (via Node.js scripts)
- Creating multiple apps in batch
- Automating app scaffolding in CI/CD pipelines
- Understanding the difference between generator approaches (yo @sap/fiori vs. fiori-elements-writer)
- Configuring app manifests and metadata compilation

## How to Invoke

From your IDE (VSCode/Cursor with Claude Code extension):

```
Generate a List Report Object Page app for my Products service
```

```
Create a Worklist app for processing pending orders
```

```
Show me how to programmatically generate 4 Fiori apps for different user roles
```

## Supported Template Types

1. **ListReportObjectPage** - Browse and edit (most common)
2. **Worklist** - Task processing with actions
3. **AnalyticalListPage** - Charts, KPIs, visual filters
4. **OverviewPage** - Dashboard with cards
5. **FormEntryObjectPage** - Data entry forms

## How It Works

1. **Install generator**: `npm install @sap-ux/fiori-elements-writer`
2. **Compile service to EDMX**: `cds compile srv/my-service.cds --to edmx`
3. **Create generation script**: Node.js script with app configuration
4. **Run script**: Generates app in `app/` folder
5. **Auto-loading**: Annotations from `app/*/annotations.cds` load automatically (December 2025)

## Key Configuration

```javascript
{
  appId: 'customer.portal',
  appTitle: 'Customer Portal',
  template: {
    type: 'ListReportObjectPage',
    settings: {
      entityType: 'RMAs',
      // ...
    }
  }
}
```

## Full Documentation

See [../../.ai/sap-fiori-scaffolder.md](../../.ai/sap-fiori-scaffolder.md) for:
- Complete generation script example (224 lines)
- All template types and configurations
- Metadata compilation process
- Error handling patterns
- CI/CD integration

## Example Usage

**Single app generation:**
```
Generate a List Report for my Orders service entity
```

**Batch generation:**
```
Create 4 apps: customer portal (LROP), agent worklist (Worklist), manager dashboard (ALP), and admin panel (LROP)
```

**Custom configuration:**
```
Generate a Worklist app with custom navigation to a specific Object Page
```
