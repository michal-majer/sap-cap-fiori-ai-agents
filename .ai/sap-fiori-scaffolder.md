---
name: sap-fiori-scaffolder
description: "Generate SAP Fiori Elements applications for CAP projects using @sap-ux/fiori-elements-writer (v2.8.9+). Updated for December 2025 CAP release."
alwaysApply: false
---

# SAP Fiori Scaffolder - Quick Recipe

## Step 1: Install Library

```bash
npm install --save-dev @sap-ux/fiori-elements-writer@^2.8.9
```

## Step 2: Create Generation Script

Create `generate-fiori-writer.mjs` in project root:

```javascript
#!/usr/bin/env node

import { generate, OdataVersion, TemplateType } from '@sap-ux/fiori-elements-writer';
import { readFileSync, execSync } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

async function generateFioriApp(config) {
  console.log(`[*] Generating ${config.appName} Fiori App...`);

  try {
    const metadataContent = execSync(
      `cds compile srv/ --to edmx-v4 --service ${config.serviceName} 2>/dev/null`,
      { encoding: 'utf-8', cwd: __dirname }
    );

    if (!metadataContent || metadataContent.trim().length === 0) {
      throw new Error(`No metadata returned for service: ${config.serviceName}`);
    }

    const appConfig = {
      app: {
        id: config.appId,
        title: config.appTitle,
        description: config.appDescription || 'Fiori Elements Application',
        flpAppId: config.appId.replace(/\./g, '-') + '-tile'
      },
      package: {
        name: config.appName,
        description: config.appDescription || 'Fiori Elements Application'
      },
      service: {
        url: config.serviceUrl || 'http://localhost:4004',
        path: `/odata/v4/${config.servicePath}/`,
        version: OdataVersion.v4,
        metadata: metadataContent
      },
      ui5: {
        version: '1.120.0',
        ui5Theme: 'sap_horizons',
        localVersion: '1.120.0'
      },
      template: {
        type: TemplateType.ListReportObjectPage,
        settings: {
          entityConfig: {
            mainEntity: {
              entityName: config.mainEntity
            }
          }
        }
      }
    };

    const outputPath = path.join(__dirname, 'app', config.appName);
    const memFs = await generate(outputPath, appConfig);

    await new Promise((resolve, reject) => {
      memFs.commit((err) => {
        if (err) {
          reject(err);
        } else {
          console.log(`  ✓ ${config.appName} app generated successfully\n`);
          resolve();
        }
      });
    });

    return outputPath;
  } catch (error) {
    console.error(`  ✗ Generation failed: ${error.message}`);
    throw error;
  }
}

async function main() {
  console.log('=== SAP Fiori Elements App Generator ===\n');

  try {
    const apps = [
      {
        appId: 'projects.app',
        appName: 'projects',
        appTitle: 'Projects',
        appDescription: 'Project Management Application',
        serviceName: 'ProjectService',
        servicePath: 'project',
        mainEntity: 'Projects'
      },
      {
        appId: 'tasks.app',
        appName: 'tasks',
        appTitle: 'Tasks',
        appDescription: 'Task Management Application with Hierarchy Support',
        serviceName: 'ProjectService',
        servicePath: 'project',
        mainEntity: 'Tasks'
      }
    ];

    for (const app of apps) {
      await generateFioriApp(app);
    }

    console.log('=== Generation Complete ===');
    console.log('\nNext steps:');
    console.log('  1. Run: cds watch');
    console.log('  2. Access: http://localhost:4004/projects/webapp/index.html');
    console.log('  3. Access: http://localhost:4004/tasks/webapp/index.html');
  } catch (error) {
    console.error('\nFailed to generate apps:', error.message);
    process.exit(1);
  }
}

main();
```

## Step 3: Run Script

```bash
node generate-fiori-writer.mjs
```

## Step 4: Add Cloud Foundry Deployment Configuration

After generating the Fiori app, add deployment configuration for CF:

```bash
# Install deployment tooling (if not already installed)
npm install --save-dev @sap/ux-ui5-tooling @ui5/cli

# Add CF deployment configuration
npx -p @sap/ux-ui5-tooling fiori add deploy-config cf
```

This adds:
- `ui5-deploy.yaml` - UI5 tooling deployment config
- Updates `package.json` with deploy scripts
- Configures HTML5 Application Repository deployment

**Alternative: Manual package.json Configuration**

If the command doesn't work, add manually to each Fiori app's `package.json`:

```json
{
  "devDependencies": {
    "@ui5/cli": "^4.0.33",
    "@sap/ux-ui5-tooling": "1"
  },
  "scripts": {
    "deploy-config": "npx -p @sap/ux-ui5-tooling fiori add deploy-config cf"
  }
}
```

## Step 5: Annotation Loading (December 2025 Update)

**Good news!** With December 2025 CAP release, CDS now **automatically loads all `.cds` files** from `app/` and its subfolders. Manual imports in service files are often no longer needed.

**If annotations are in `app/*/annotations.cds`:**
- They are auto-loaded - no manual import required!
- Place annotations in: `app/projects/annotations.cds`, `app/tasks/annotations.cds`

**If annotations are in `srv/annotations/`:**
- You still need to import them in your service file:

```cds
using pm from '../db/schema';

// Import UI annotations (only needed if NOT in app/ folder)
using from './annotations/projects';
using from './annotations/tasks';

service ProjectService @(requires: 'authenticated-user') {
  // ... rest of service
}
```

**Verify annotations are loaded:** Check browser DevTools → Network tab that `/metadata` includes UI annotations.

**Without annotations, Fiori Elements won't render:**
- FilterBar fields
- Table columns
- Detail page layouts
- Value lists and dropdowns

---

## CRITICAL: Avoiding Duplicate Annotation Errors

**When multiple Fiori apps use the SAME service entity**, you MUST use shared annotations or qualified annotation patterns to avoid CDS compilation errors.

### Problem
If `app/rma-manage/annotations.cds` and `app/rma-inspect/annotations.cds` both define `@UI.HeaderInfo` for `RMAService.RMAs`, CDS will fail with:
```
[ERROR] Duplicate assignment with "@UI.HeaderInfo.TypeNamePlural"
```

### Solution: Shared Common Annotations

Create `app/common-annotations.cds` for shared annotations:

```cds
using RMAService as service from '../srv/rma-service';

// Shared annotations - used by ALL apps
annotate service.RMAs with @(
    UI.HeaderInfo : {
        TypeName : 'RMA',
        Title : { Value : rmaNumber }
    },
    UI.Facets : [ /* Object Page sections */ ],
    UI.FieldGroup #GeneralInfo : { /* Fields */ }
);

// Field-level annotations (labels, value helps)
annotate service.RMAs with {
    rmaNumber @Common.Label : 'RMA Number';
    customer @Common.ValueList : { /* ... */ };
};
```

Then each app imports common and adds ONLY app-specific annotations:

```cds
// app/rma-manage/annotations.cds
using from '../common-annotations';  // Import shared
using RMAService as service from '../../srv/rma-service';

// App-specific ONLY - LineItem, SelectionFields, Identification
annotate service.RMAs with @(
    UI.SelectionFields : [rmaNumber, status_code],
    UI.LineItem : [
        { Value : rmaNumber },
        { Value : status_code, Criticality : criticality }
    ],
    UI.Identification : [
        { $Type : 'UI.DataFieldForAction', Action : 'RMAService.approve' }
    ]
);
```

### Rules for Multiple Apps Using Same Entity

| Annotation Type | Where to Define | Why |
|-----------------|-----------------|-----|
| `@UI.HeaderInfo` | `common-annotations.cds` | Same title for all apps |
| `@UI.Facets` | `common-annotations.cds` | Same Object Page structure |
| `@UI.FieldGroup` | `common-annotations.cds` | Same field groupings |
| Field labels (`@Common.Label`) | `common-annotations.cds` | Consistent naming |
| Value helps (`@Common.ValueList`) | `common-annotations.cds` | Same dropdowns |
| `@UI.LineItem` | `app/*/annotations.cds` | Different columns per app |
| `@UI.SelectionFields` | `app/*/annotations.cds` | Different filters per app |
| `@UI.Identification` | `app/*/annotations.cds` | Different actions per app |

### Before Generating Second+ App

**ALWAYS check:** Does another app already annotate this service entity?
```bash
grep -r "RMAService.RMAs" app/*/annotations.cds
```

If yes → Create `common-annotations.cds` and refactor first app before generating second.

---

## Step 6: Verify

```bash
ls -la app/projects/webapp/
ls -la app/tasks/webapp/

cds watch
# Visit: http://localhost:4004/projects/webapp/index.html
# Visit: http://localhost:4004/tasks/webapp/index.html
```

Check browser DevTools → Network tab that `/metadata` includes UI annotations.

---

## Template Types

```javascript
TemplateType.ListReportObjectPage    // Browse + edit
TemplateType.Worklist                // Task processing
TemplateType.AnalyticalListPage      // Charts + KPIs
TemplateType.OverviewPage            // Dashboard
TemplateType.FormEntryObjectPage     // Data entry form
```

---

## Customize Script

Edit `generate-fiori-writer.mjs` to add more apps. Modify the `apps` array:

```javascript
{
  appId: 'myapp.app',
  appName: 'myapp',
  appTitle: 'My App',
  appDescription: 'Description',
  serviceName: 'MyService',
  servicePath: 'myservice',
  mainEntity: 'EntityName'
}
```

**Key points:**

- `serviceName`: Match your CDS service name exactly
- `mainEntity`: Match your entity name in the service
- Metadata extracted with `2>/dev/null` to suppress warnings
