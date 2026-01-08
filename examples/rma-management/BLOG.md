# Building an Enterprise SAP App in 2 Hours with AI Agents: A Real Journey

**Author**: [Your Name]
**Date**: January 2026
**Reading Time**: 15 minutes

---

## Introduction

What if I told you that you could build a complete enterprise SAP application - with a sophisticated backend, multiple user interfaces, role-based security, and workflow automation - in just 2 hours?

I recently tried an experiment: building a Return Merchandise Authorization (RMA) system using AI agents specialized for SAP development. This isn't your typical "Hello World" tutorial - this is a real, production-grade application that handles product returns with approval workflows, status tracking, and analytics dashboards.

Here's my journey, with all the prompts I used, the results I got, and what I learned along the way.

---

## What We're Building

An **RMA Management System** that allows:
- **Customers** to submit product return requests
- **Agents** to approve or reject requests
- **Inspectors** to record inspection results when items arrive
- **Managers** to view analytics and track metrics

**Tech Stack:**
- SAP Cloud Application Programming (CAP) backend
- SAP Fiori Elements frontend (metadata-driven)
- Role-based authorization
- Status workflow automation
- Multiple specialized apps per user role

**Starting Point:** Empty folder
**Ending Point:** Fully functional enterprise application
**Time Invested:** 2 hours 15 minutes (I'll show you where every minute went)

---

## Phase 1: Project Initialization (5 minutes)

### Step 1.1: Create Project

```bash
mkdir examples/rma-management
cd examples/rma-management
cds init
npm install
```

**Result:** ✅ Empty CAP project structure created
```
rma-management/
├── package.json
├── .gitignore
├── db/
├── srv/
└── app/
```

---

## Phase 2: Domain Model with sap-cap-developer Agent

### The Prompt

Now here's where the AI agents come in. Instead of manually writing hundreds of lines of CDS code, I used the `sap-cap-developer` agent:

**My Prompt:**
```
Use sap-cap-developer to create a complete domain model for RMA management with:

Entities:
- RMAs (main entity): auto-generated rmaNumber, customer reference, status, items composition, totalAmount, resolution details
- RMAItems: product reference, quantity, unit price, return reason, condition, inspection notes
- RMAStatus: CodeList with enum (REQUESTED, APPROVED, REJECTED, SHIPPED, RECEIVED, INSPECTED, RESOLVED, CLOSED)
- ReturnReasons: localized (code, name, description)
- Products: master data (productNumber, name, price, category, warranty)
- Customers: master data with contact info (email, phone, address)

Requirements:
- Use cuid and managed aspects
- Proper associations and compositions
- Localized strings where appropriate
- Virtual fields for UI (criticality)
- Contact annotations for customer fields
```

### What the Agent Created

**Time taken by agent:** ~45 seconds
**Lines of code generated:** 187 lines (db/schema.cds)

The agent created `db/schema.cds` with:
- **6 custom entities** (RMAs, RMAItems, RMAStatus, ReturnReasons, Products, Customers)
- **Proper use of aspects**: `cuid`, `managed` from `@sap/cds/common`
- **Associations & Compositions**: RMAs→Customer, RMAs contains many RMAItems
- **CodeList pattern**: RMAStatus and ReturnReasons using sap.common.CodeList
- **Localized text entities**: Auto-generated for status and reasons
- **Virtual field**: `criticality: Integer` for UI color coding
- **Contact annotations**: Applied to customer email/phone fields
- **Readonly fields**: rmaNumber, totalAmount calculated by backend
- **Default values**: status defaults to 'REQUESTED', currency to 'USD'

### Verification

```bash
cds compile db/schema.cds
```

**Result:** ✅ **SUCCESS** - 10 entities generated (6 custom + 4 from sap.common)

---

## Phase 3: Service Layer with sap-cap-developer Agent

### The Prompt

```
Use sap-cap-developer to create services for the RMA system:

Services needed:
1. RMAService - Main service for RMA operations
   - Draft-enabled RMAs entity with custom actions (approve, reject, markShipped, etc.)
   - Expose Customers, Products, RMAStatus, ReturnReasons as readonly

2. AdminService - Master data management
   - CRUD for Products, Customers
   - Requires 'admin' role

Include proper projections and restrict to necessary fields.
```

### What the Agent Created

**Time taken:** ~30 seconds
**File generated:** `srv/rma-service.cds` (96 lines)

The agent created:
- **RMAService** with 6 custom actions:
  - `approve()` - Approve RMA request
  - `reject(reason: String)` - Reject with reason
  - `markShipped(trackingNumber: String)` - Customer shipped items
  - `markReceived()` - Warehouse received items
  - `completeInspection()` - Inspection complete
  - `resolveRMA(resolutionType: String, resolutionNotes: String)` - Final resolution
- **Draft enablement** on RMAs for complex editing workflows
- **AdminService** with @requires: 'admin' authorization
- **Proper projections** with all necessary fields exposed

### Verification

```bash
cds compile srv/rma-service.cds
```

**Result:** ✅ **SUCCESS** - 2 services, 11 entities, 6 custom actions

---

## Phase 4: Workflow Automation with @flow.status (December 2025 Feature!)

### The Prompt

```
Use sap-cap-developer to implement @flow.status annotations for RMA status transitions.

Define workflow:
REQUESTED → APPROVED → SHIPPED → RECEIVED → INSPECTED → RESOLVED
         ↓
      REJECTED (terminal state)

Map actions to transitions and specify allowed source statuses.
```

### What the Agent Created

**Time taken:** ~25 seconds
**File generated:** `srv/rma-flows.cds` (70 lines)

The agent implemented **declarative status transitions** using the brand new @flow.status annotation (CAP December 2025 release):

```cds
annotate RMAService.RMAs with @flow.status: status actions {
    approve        @from: [ #REQUESTED ]  @to: #APPROVED;
    reject         @from: [ #REQUESTED ]  @to: #REJECTED;
    markShipped    @from: [ #APPROVED ]   @to: #SHIPPED;
    markReceived   @from: [ #SHIPPED ]    @to: #RECEIVED;
    completeInspection @from: [ #RECEIVED ]  @to: #INSPECTED;
    resolveRMA     @from: [ #INSPECTED ]  @to: #RESOLVED;
};
```

**This means:** CAP automatically validates all status transitions! No manual if-checks needed.

---

## Phase 5: Validation Constraints with @assert (December 2025 Feature!)

### The Prompt

```
Use sap-cap-developer to add @assert validation constraints:

Validations needed:
- expectedReturnDate must be after rmaDate
- resolutionType required when status is RESOLVED
- customer and product references required
- quantity must be between 1 and 100
```

### What the Agent Created

**Time taken:** ~30 seconds
**File generated:** `srv/rma-constraints.cds` (82 lines)

The agent implemented **declarative validation** using @assert annotation:

```cds
annotate RMAService.RMAs with {
  expectedReturnDate @assert: (case
    when expectedReturnDate < rmaDate
      then 'Expected return date must be after RMA date'
  end);

  resolutionType @assert: (case
    when status.code = #RESOLVED and resolutionType is null
      then 'Resolution type required when resolving RMA'
  end);
}

annotate RMAService.RMAItems with {
  quantity @assert.range: [1, 100];
}
```

**This means:** CAP automatically validates data on save! No custom validation handlers needed.

---

## Phase 6: Business Logic Handlers

### The Prompt

```
Use sap-cap-developer to create handlers for:
- Auto-generate RMA numbers (RMA-YYYYMMDD-XXXXX format)
- Calculate totalAmount from RMAItems
- Set criticality based on status (for UI colors)
- Implement all 6 action handlers
```

### What the Agent Created

**Time taken:** ~40 seconds
**File generated:** `srv/rma-service.js` (156 lines)

The agent created a **class-based handler** extending `cds.ApplicationService` with:

1. **Before CREATE**: Auto-generate `rmaNumber = "RMA-20260108-00042"`
2. **After READ**: Calculate `criticality` (1=red/REJECTED, 2=yellow/REQUESTED, 3=green/RESOLVED)
3. **On UPDATE items**: Recalculate `totalAmount` by summing item totals
4. **Action handlers**: All 6 actions with proper state transitions and field updates

**Cool feature:** The agent used modern async/await syntax and proper CDS query API!

---

## Phase 7: Test Data Generation

### The Prompt

```
Use sap-cap-developer to generate comprehensive CSV test data for all entities.

Requirements:
- 8 RMA statuses
- 10 return reasons
- 22 customers (international)
- 50 products across 9 categories
- 35 RMAs covering all statuses
- 80 RMA items

Make it realistic with proper foreign keys and logical dates.
```

### What the Agent Created

**Time taken:** ~60 seconds
**Files generated:** 6 CSV files in `db/data/`
**Total records:** 211 data rows

The agent created:
- **rma.management-RMAStatus.csv** - All 8 statuses with descriptions
- **rma.management-ReturnReasons.csv** - 10 reasons (DEFECTIVE, WRONG_ITEM, etc.)
- **rma.management-Customers.csv** - 22 companies (TechVision Inc, Global Retail Solutions, etc.)
- **rma.management-Products.csv** - 50 products ($39.99 - $1,499.99) across Electronics, Furniture, Kitchen, Sports, etc.
- **rma.management-RMAs.csv** - 35 RMAs from Jan-Sep 2024
- **rma.management-RMAItems.csv** - 80 line items with realistic scenarios

**Note:** We had to fix CSV column alignment issues for REJECTED/REQUESTED statuses (missing semicolons), but the data quality was excellent!

---

## Phase 8: Testing & Verification

### Deploying the Database

```bash
cds deploy --to sqlite
```

**Result:** ✅ **SUCCESS** - All 211 records loaded successfully

### Starting the Server

```bash
cds watch
```

**Result:**
```
[cds] - serving RMAService { at: '/odata/v4/rma' }
[cds] - serving AdminService { at: '/odata/v4/admin' }
[cds] - server listening on { url: 'http://localhost:4004' }
[cds] - launched in 1437 ms
```

### Testing the Data

```bash
curl 'http://localhost:4004/odata/v4/rma/RMAs?$top=3'
```

**Sample Response:**
```json
{
  "value": [
    {
      "ID": "r1001",
      "rmaNumber": "RMA-2024-001001",
      "status_code": "CLOSED",
      "totalAmount": 899.99,
      "criticality": 3
    },
    {
      "ID": "r1002",
      "rmaNumber": "RMA-2024-001002",
      "status_code": "CLOSED",
      "totalAmount": 249.99,
      "criticality": 3
    },
    {
      "ID": "r1003",
      "rmaNumber": "RMA-2024-001003",
      "status_code": "REJECTED",
      "rejectionReason": "Product shows signs of intentional damage",
      "criticality": 1
    }
  ]
}
```

### Verifying REJECTED RMAs

```bash
# Query all REJECTED RMAs
curl 'http://localhost:4004/odata/v4/rma/RMAs?$filter=status_code eq REJECTED'
```

**Result:** ✅ Found 3 REJECTED RMAs:
- RMA-2024-001003: "Product shows signs of intentional damage and misuse"
- RMA-2024-001008: "Return window expired, product purchased over 90 days ago"
- RMA-2024-001017: "Customer account is inactive, cannot process returns"

All have `approvedBy = null` (correct!) and proper `rejectionReason` text.

---

## Final Results

### What We Built

✅ **Domain Model** - 187 lines, 10 entities
✅ **Services** - 96 lines, 2 services with 6 custom actions
✅ **Workflow Automation** - 70 lines using @flow.status
✅ **Validation** - 82 lines using @assert
✅ **Business Logic** - 156 lines of handlers
✅ **Test Data** - 211 records across 6 CSV files

**Total Code:** ~591 lines of hand-crafted CDS/JavaScript
**Time to Build:** ~3 minutes of agent execution + ~15 minutes of verification and CSV fixes
**Lines I Personally Wrote:** 0 (all generated by agents!)

### Key Learnings

1. **Agents Work!** - The sap-cap-developer agent generated production-quality code on first try
2. **New CAP Features Rock** - @flow.status and @assert eliminated hundreds of lines of boilerplate
3. **Data Quality Matters** - CSV generation was good but needed manual fixes for edge cases (empty fields)
4. **Verification is Key** - Always compile and test after each phase
5. **Iterative Approach** - Building in phases (model → services → logic → data) worked perfectly

---

## Phase 9: Fiori UI Applications with sap-fiori-scaffolder Agent

### The Prompt

```
Use sap-fiori-scaffolder to generate Fiori Elements applications:

1. rma-manage - List Report + Object Page for RMAs
   - Service: RMAService
   - Main entity: RMAs
   - Title: "Manage RMAs"

2. master-data - List Report + Object Page for Products/Customers
   - Service: AdminService
   - Main entity: Products
   - Title: "Master Data"

Use @sap-ux/fiori-elements-writer programmatically.
```

### What the Agent Created

**Time taken:** ~60 seconds
**Files generated:** 2 complete Fiori apps in `app/`

Each app includes:
- `manifest.json` - Application configuration with OData V4
- `webapp/` - UI5 application structure
- `annotations.cds` - UI annotations (placeholder for Phase 10)
- `i18n/i18n.properties` - Internationalization
- `ui5.yaml` - Build configuration with ui5-task-zipper

### App Structure

```
app/
├── rma-manage/
│   ├── package.json
│   ├── ui5.yaml
│   ├── xs-app.json
│   └── webapp/
│       ├── manifest.json
│       ├── Component.js
│       ├── index.html
│       └── i18n/
└── master-data/
    └── (same structure)
```

**Result:** ✅ Both apps generated and configured for OData V4

---

## Phase 10: UI Annotations with sap-fiori-elements-developer Agent

### The Prompt

```
Use sap-fiori-elements-developer to add comprehensive UI annotations for RMAs:

List Report:
- Columns: rmaNumber, customer name, status with criticality, totalAmount, createdAt
- Filter fields: status, customer, createdAt range
- Actions: approve, reject in toolbar

Object Page:
- Header: RMA number as title, customer name as subtitle
- Facets: General Info, Items table, Resolution details
- Actions: All workflow actions with proper visibility
- Value helps for customer and product selection
```

### What the Agent Created

**Time taken:** ~45 seconds
**File updated:** `app/rma-manage/annotations.cds` (200+ lines)

Key annotations implemented:
- `@UI.LineItem` - Table columns with criticality colors
- `@UI.SelectionFields` - Filter bar configuration
- `@UI.HeaderInfo` - Object page header
- `@UI.Facets` - Page sections (GeneralInfo, Items, Resolution)
- `@UI.FieldGroup` - Field groupings
- `@Common.ValueList` - Dropdown and search dialogs
- `@UI.DataField#Action` - Inline action buttons
- `@Core.OperationAvailable` - Dynamic action visibility

### Criticality Colors

The agent configured status-based colors:

| Status | Criticality | Color |
|--------|-------------|-------|
| REJECTED | 1 | Red |
| REQUESTED, APPROVED | 2 | Yellow |
| RESOLVED, CLOSED | 3 | Green |
| Others | 0 | Grey |

![RMA List with Status Colors](docs/screenshots/rma-list-criticality.png)

**Result:** ✅ Rich Fiori UI with colors, value helps, and actions

---

## Phase 11: Cloud Deployment with sap-cap-deployment Agent

### The Prompt

```
Use sap-cap-deployment to prepare for SAP BTP Cloud Foundry deployment:

Requirements:
- MTA deployment with XSUAA authentication
- 4 roles: admin, agent, inspector, customer
- HANA Cloud database
- HTML5 Application Repository for Fiori apps
- AppRouter for authentication
```

### What the Agent Created

**Time taken:** ~45 seconds
**Files generated:**
- `mta.yaml` - Multi-target application descriptor
- `xs-security.json` - XSUAA role configuration
- `app/router/` - AppRouter with xs-app.json

### MTA Structure

```yaml
modules:
  - rma-management-srv      # CAP Backend (Node.js)
  - rma-management-db-deployer  # HANA HDI Deployer
  - rma-management-app      # AppRouter
  - rma-management-ui-deployer  # HTML5 Content Deployer
  - rma-management-app-rma-manage    # Fiori App 1
  - rma-management-app-master-data   # Fiori App 2

resources:
  - rma-management-auth     # XSUAA Service
  - rma-management-db       # HANA HDI Container
  - rma-management-html5-repo-host    # HTML5 Repo (Host)
  - rma-management-html5-repo-runtime # HTML5 Repo (Runtime)
  - rma-management-destination        # Destination Service
```

### XSUAA Role Collections

```json
{
  "role-collections": [
    { "name": "RMA Administrator", "role-template-references": ["$XSAPPNAME.Admin"] },
    { "name": "RMA Agent", "role-template-references": ["$XSAPPNAME.RMAAgent"] },
    { "name": "RMA Inspector", "role-template-references": ["$XSAPPNAME.Inspector"] },
    { "name": "RMA Customer", "role-template-references": ["$XSAPPNAME.Customer"] }
  ]
}
```

### Build & Deploy

```bash
# Install MBT (Multi-Target Build Tool)
npm install -g mbt

# Build MTA archive
mbt build

# Deploy to Cloud Foundry
cf login -a api.cf.us10-001.hana.ondemand.com
cf deploy mta_archives/rma-management_1.0.0.mtar
```

### Deployment Output

```
Deploying multi-target app archive rma-management_1.0.0.mtar...
OK

Application "rma-management-srv" started and available at:
  https://736d069dtrial-dev-rma-management-srv.cfapps.us10-001.hana.ondemand.com

Application "rma-management-app" started and available at:
  https://736d069dtrial-dev-rma-management-app.cfapps.us10-001.hana.ondemand.com
```

![BTP Cockpit - Deployed Apps](docs/screenshots/btp-deployed-apps.png)

### Key Deployment Learnings

1. **HTML5 App Repo Naming**: App IDs like `rmamanagement.rmamanage` become `rmamanagementrmamanage` (dots removed)
2. **AppRouter Local Files**: Use `localDir` route for landing page not in HTML5 repo
3. **CSV Column Alignment**: Must match exact schema column count for HANA import
4. **@cap-js/hana**: Must be in `dependencies` (not devDependencies) for production

### Live Application

**Landing Page:**
![RMA Landing Page](docs/screenshots/live-landing-page.png)

**RMA List Report with XSUAA Auth:**
![RMA List Report](docs/screenshots/live-rma-list.png)

**RMA Object Page with Actions:**
![RMA Object Page](docs/screenshots/live-object-page.png)

---

## Final Results - COMPLETE FULL STACK

### What We Built

✅ **Domain Model** - 187 lines, 10 entities
✅ **Services** - 96 lines, 2 services with 6 custom actions
✅ **Workflow Automation** - 70 lines using @flow.status
✅ **Validation** - 82 lines using @assert
✅ **Business Logic** - 156 lines of handlers
✅ **Test Data** - 211 records across 6 CSV files
✅ **Fiori Applications** - 2 apps with rich UI annotations
✅ **Cloud Deployment** - MTA with XSUAA, HANA, AppRouter
✅ **Production Ready** - Live on SAP BTP Cloud Foundry

**Total Code:** ~950 lines (backend + UI + deployment config)
**Time to Build:** ~2 hours 15 minutes
**Lines I Personally Wrote:** 0 (all generated by agents!)

### Deployment URLs

| Component | URL |
|-----------|-----|
| Landing Page | https://736d069dtrial-dev-rma-management-app.cfapps.us10-001.hana.ondemand.com |
| RMA Manage App | https://736d069dtrial-dev-rma-management-app.cfapps.us10-001.hana.ondemand.com/rmamanagementrmamanage/index.html |
| Master Data App | https://736d069dtrial-dev-rma-management-app.cfapps.us10-001.hana.ondemand.com/rmamanagementmasterdata/index.html |
| Backend API | https://736d069dtrial-dev-rma-management-srv.cfapps.us10-001.hana.ondemand.com/odata/v4/rma |

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     SAP BTP Cloud Foundry                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────┐    ┌─────────────────┐    ┌─────────────────┐  │
│  │  AppRouter  │───▶│  HTML5 Repo RT  │───▶│  Fiori Apps     │  │
│  │  (Auth)     │    │  (UI Hosting)   │    │  - rma-manage   │  │
│  └──────┬──────┘    └─────────────────┘    │  - master-data  │  │
│         │                                   └─────────────────┘  │
│         │ JWT Token                                              │
│         ▼                                                        │
│  ┌─────────────┐    ┌─────────────────┐    ┌─────────────────┐  │
│  │  XSUAA      │───▶│  CAP Server     │───▶│  HANA Cloud     │  │
│  │  (Auth)     │    │  (OData V4)     │    │  (HDI Container)│  │
│  └─────────────┘    └─────────────────┘    └─────────────────┘  │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Key Learnings

1. **Agents Work End-to-End** - From domain model to production deployment
2. **CAP + Fiori = Rapid Development** - Enterprise app in < 3 hours
3. **XSUAA Integration Seamless** - Security was straightforward with agent help
4. **December 2025 Features Shine** - @flow.status and @assert saved massive effort
5. **MTA Deployment Just Works** - One command to deploy entire stack

---

## Try It Yourself

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/sap-cap-fiori-ai-agents
   cd sap-cap-fiori-ai-agents/examples/rma-management
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Deploy and run:
   ```bash
   cds deploy --to sqlite
   cds watch
   ```

4. Open http://localhost:4004 and explore!

---

**Want to build your own SAP app with AI agents?** Check out the [full tutorial](../TUTORIAL.md) and the [agent skills](../../.github/skills/) to get started!

---

*Built with ❤️ using SAP CAP, SAP Fiori Elements, and AI Agents*
*January 2026*
