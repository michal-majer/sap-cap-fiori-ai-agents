#!/usr/bin/env node

/**
 * Fiori Elements Application Generator Script
 *
 * This script generates 3 Fiori Elements applications for the RMA Management System:
 * 1. rma-manage - Main RMA management application
 * 2. rma-inspect - Inspector application for recording inspection results
 * 3. master-data - Administrative application for managing products and customers
 *
 * Prerequisites:
 * - @sap-ux/fiori-elements-writer must be installed (npm install --save-dev @sap-ux/fiori-elements-writer)
 * - CAP server should be running at http://localhost:4004
 *
 * Usage:
 *   node generate-fiori-apps.mjs
 */

import { generate, TemplateType, OdataVersion } from '@sap-ux/fiori-elements-writer';
import { join } from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Base configuration
const baseDir = __dirname;
const ui5Version = '1.120.0';
const ui5Theme = 'sap_horizons';

/**
 * Application configurations
 */
const applications = [
  {
    id: 'rmamanagement.rmamanage',
    title: 'Manage Returns',
    description: 'Main application for managing Return Merchandise Authorizations',
    service: 'RMAService',
    servicePath: '/odata/v4/rma',
    entity: 'RMAs',
    appDir: 'rma-manage'
  },
  {
    id: 'rmamanagement.rmainspect',
    title: 'Inspect Returns',
    description: 'Inspector application for recording inspection results',
    service: 'RMAService',
    servicePath: '/odata/v4/rma',
    entity: 'RMAs',
    appDir: 'rma-inspect'
  },
  {
    id: 'rmamanagement.masterdata',
    title: 'Master Data',
    description: 'Administrative application for managing products and customers',
    service: 'AdminService',
    servicePath: '/odata/v4/admin',
    entity: 'Products',
    appDir: 'master-data'
  }
];

/**
 * Generate a single Fiori Elements application
 */
async function generateApp(appConfig) {
  console.log(`\n${'='.repeat(80)}`);
  console.log(`Generating Fiori app: ${appConfig.title} (${appConfig.id})`);
  console.log(`${'='.repeat(80)}\n`);

  const config = {
    app: {
      id: appConfig.id,
      title: appConfig.title,
      description: appConfig.description,
      flpAppId: appConfig.id
    },
    package: {
      name: appConfig.appDir
    },
    service: {
      url: 'http://localhost:4004',
      path: appConfig.servicePath,
      version: OdataVersion.v4
    },
    ui5: {
      localVersion: ui5Version,
      version: ui5Version,
      ui5Theme: ui5Theme,
      minUI5Version: '1.120.0'
    },
    appOptions: {
      loadReuseLibs: true,
      addTests: false,
      addAnnotations: true
    },
    template: {
      type: TemplateType.ListReportObjectPage,
      settings: {
        entityConfig: {
          mainEntityName: appConfig.entity
        }
      }
    }
  };

  try {
    const targetDir = join(baseDir, 'app', appConfig.appDir);

    console.log('Configuration:');
    console.log('  Target Directory:', targetDir);
    console.log('  Service:', appConfig.service);
    console.log('  Service Path:', appConfig.servicePath);
    console.log('  Main Entity:', appConfig.entity);
    console.log('  UI5 Version:', ui5Version);
    console.log('  UI5 Theme:', ui5Theme);

    // Generate the application
    const fs = await generate(targetDir, config);

    // Commit the file system changes
    await new Promise((resolve, reject) => {
      fs.commit((err) => {
        if (err) reject(err);
        else resolve();
      });
    });

    console.log(`\n✓ Successfully generated ${appConfig.title}`);
    console.log(`  Location: ${targetDir}`);

    return { success: true, appConfig, targetDir };
  } catch (error) {
    console.error(`\n✗ Error generating ${appConfig.title}:`);
    console.error(error.message);
    if (error.stack) {
      console.error('\nStack trace:');
      console.error(error.stack);
    }
    return { success: false, appConfig, error };
  }
}

/**
 * Main execution function
 */
async function main() {
  console.log('\n');
  console.log('╔═══════════════════════════════════════════════════════════════════════════════╗');
  console.log('║                 SAP Fiori Elements Application Generator                     ║');
  console.log('║                      RMA Management System                                    ║');
  console.log('╚═══════════════════════════════════════════════════════════════════════════════╝');
  console.log('\n');

  console.log('Configuration Summary:');
  console.log('  Base Directory:', baseDir);
  console.log('  UI5 Version:', ui5Version);
  console.log('  UI5 Theme:', ui5Theme);
  console.log('  Applications to generate:', applications.length);
  console.log('\n');

  const results = [];

  // Generate each application
  for (const appConfig of applications) {
    const result = await generateApp(appConfig);
    results.push(result);

    // Add a small delay between generations to avoid potential race conditions
    await new Promise(resolve => setTimeout(resolve, 1000));
  }

  // Summary
  console.log('\n');
  console.log('╔═══════════════════════════════════════════════════════════════════════════════╗');
  console.log('║                         Generation Summary                                    ║');
  console.log('╚═══════════════════════════════════════════════════════════════════════════════╝');
  console.log('\n');

  const successful = results.filter(r => r.success);
  const failed = results.filter(r => !r.success);

  console.log(`Total applications: ${results.length}`);
  console.log(`  ✓ Successful: ${successful.length}`);
  console.log(`  ✗ Failed: ${failed.length}`);
  console.log('\n');

  if (successful.length > 0) {
    console.log('Successfully generated applications:');
    successful.forEach(r => {
      console.log(`  ✓ ${r.appConfig.title} (${r.appConfig.id})`);
      console.log(`    Location: ${r.targetDir}`);
    });
    console.log('\n');
  }

  if (failed.length > 0) {
    console.log('Failed applications:');
    failed.forEach(r => {
      console.log(`  ✗ ${r.appConfig.title} (${r.appConfig.id})`);
      console.log(`    Error: ${r.error.message}`);
    });
    console.log('\n');
  }

  console.log('Next Steps:');
  console.log('  1. Review the generated applications in the app/ directory');
  console.log('  2. Add UI annotations in app/*/annotations.cds files');
  console.log('  3. Customize the applications as needed');
  console.log('  4. Run "cds watch" to test the applications');
  console.log('\n');

  // Exit with appropriate code
  process.exit(failed.length > 0 ? 1 : 0);
}

// Run the script
main().catch(error => {
  console.error('\n✗ Fatal error:');
  console.error(error);
  process.exit(1);
});
