---
name: sap-fiori-scaffolder
description: "Generate SAP Fiori Elements applications for CAP projects using @sap-ux/fiori-elements-writer (v2.8.9+)"
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

## Step 4: Import Annotations in Service (CRITICAL)

After generation, **manually add annotation imports** to `srv/project-service.cds`:

```cds
using pm from '../db/schema';

// Import UI annotations ← ADD THIS
using from './annotations/projects';
using from './annotations/tasks';

service ProjectService @(requires: 'authenticated-user') {
  // ... rest of service
}
```

**Why?** The scaffolder generates apps but doesn't include backend annotations in the service metadata. Without this import, Fiori Elements won't render:

- FilterBar fields
- Table columns
- Detail page layouts
- Value lists and dropdowns

## Step 5: Verify

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
