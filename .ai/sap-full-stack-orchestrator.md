---
name: sap-full-stack-orchestrator
description: Master orchestrator for end-to-end SAP CAP + Fiori development. Guides through backend setup, domain modeling, service creation, Fiori app generation, and annotation enhancement in a structured workflow. Updated for December 2025 CAP release.
alwaysApply: false
---

# SAP Full-Stack Development Orchestrator

## Overview

This orchestrator guides Claude through complete SAP CAP + Fiori application development in a systematic, step-by-step process.

## Workflow Phases

### Phase 1: Requirements Gathering
**Goal:** Understand what to build

**Claude asks:**
1. What is the business domain? (e.g., Time Tracking, Inventory, RMA Management)
2. What are the main entities? (e.g., Projects, Employees, Products)
3. What are the key user roles? (e.g., Admin, Manager, Employee)
4. What are the main use cases? (e.g., "Managers approve timesheets", "Employees log hours")
5. Do you need multi-language support?
6. Is this multi-tenant (SaaS) or single-tenant?

**Output:** Clear domain understanding documented in conversation

---

### Phase 2: Backend Foundation (USE: sap-cap-developer)
**Goal:** Create working CAP backend

**Steps:**
1. **Read the skill:** See `.ai/sap-cap-developer.md`
2. **Initialize project:**
```bash
   cds init .
```
3. **Create domain model** (`db/schema.cds`):
   - Define namespace
   - Create entities with `cuid`, `managed` aspects
   - Define associations (NOT foreign keys)
   - Add `localized` fields if multi-language needed
   - Use CodeList pattern for status entities
4. **Create seed data** (`db/data/*.csv`):
   - Follow naming: `<namespace>-<EntityName>.csv`
   - Include realistic test data
   - If localized: create `_texts.csv` files
5. **Test database:**
```bash
   cds watch
```
   Verify: http://localhost:4004

**Output:** Working domain model with test data

---

### Phase 3: Service Layer (USE: sap-cap-developer)
**Goal:** Expose services with proper authorization

**Steps:**
1. **Create service definitions** (`srv/*-service.cds`):
   - Define use-case specific services (NOT mega-service)
   - Create projections (denormalized views)
   - Add custom actions if needed
   - Example services: `CatalogService` (read-only), `AdminService` (full CRUD)
2. **Add status flows** (`srv/*-flows.cds`) - December 2025 feature:
   - Use `@flow.status` for declarative state transitions
   - Example:
   ```cds
   annotate Service.Entity with @flow.status: Status actions {
     approve @from: [ #Pending ] @to: #Approved;
     reject  @from: [ #Pending ] @to: #Rejected;
   }
   ```
3. **Add constraints** (`srv/*-constraints.cds`) - December 2025 feature:
   - Use `@assert` for declarative validation
   - Example:
   ```cds
   annotate Service.Entity with {
     field @assert: (case when field < 0 then 'Must be positive' end);
   }
   ```
4. **Add authorization** (`srv/access-control.cds`):
   - Service-level: `@(requires: 'admin')`
   - Entity-level: `@restrict` annotations
   - Match roles with mocked users in package.json
5. **Create custom handlers** (`srv/*-service.js`) if needed:
   - Validation in `before` handlers
   - Business logic in `on` handlers
   - Enrichment in `after` handlers
   - Use `req.error()` for validation, `req.reject()` for failures
6. **Add mocked authentication** (package.json):
```json
   {
     "cds": {
       "auth": {
         "[development]": {
           "kind": "mocked",
           "users": {
             "admin": { "password": "admin", "roles": ["admin", "authenticated-user"] },
             "user": { "password": "user", "roles": ["authenticated-user"] }
           }
         }
       }
     }
   }
```
7. **Test services:**
```bash
   cds watch
```
   Verify: http://localhost:4004

**Output:** Working services with authorization

---

### Phase 4: Frontend Planning (USE: sap-fiori-designer)
**Goal:** Design optimal Fiori apps for each use case

**Steps:**
1. **Read the skill:** See `.ai/sap-fiori-designer.md`
2. **For each user role/use case, decide:**
   - **List Report Object Page (LROP):** CRUD operations, search, filters
   - **Analytical List Page (ALP):** KPIs, charts, analytics
   - **Overview Page (OVP):** Dashboard with multiple cards
   - **Worklist:** Task-focused, simple table
   - **Freestyle:** Complex custom UI (avoid if possible)
3. **Document app architecture:**
```
   Apps to create:
   1. Time Entry App (LROP) - for Employees
      - Entity: TimeEntries
      - Features: Create, Edit, Delete own entries
   2. Approval App (LROP) - for Managers
      - Entity: TimeEntries
      - Features: Approve/Reject entries
   3. Analytics Dashboard (ALP) - for Managers
      - Entity: TimeEntries
      - Features: Charts, filters by project/employee
```

**Output:** Clear app architecture plan

---

### Phase 5: Frontend Scaffolding (USE: sap-fiori-scaffolder)
**Goal:** Generate Fiori Elements apps

**Steps:**
1. **Read the skill:** See `.ai/sap-fiori-scaffolder.md`
2. **For each app, run Fiori generator:**
```bash
   cd app/
   yo @sap/fiori
```
   Follow prompts:
   - Template type (e.g., List Report Object Page)
   - Data source (use local CAP service)
   - Service name
   - Entity set
   - Module/app name
3. **Configure app in `app/` folder:**
   - Update `manifest.json` if needed
   - Add to `package.json` cds configuration
4. **Test app:**
```bash
   cds watch
```
   Verify: http://localhost:4004/app-name/webapp/index.html

**Output:** Generated Fiori apps

---

### Phase 6: UI Enhancement (USE: sap-fiori-elements-developer)
**Goal:** Add annotations for rich UI

**Steps:**
1. **Read the skill:** See `.ai/sap-fiori-elements-developer.md`
2. **Create annotation files** (`srv/annotations/*.cds` or `app/*/annotations.cds`):
   - `@UI.HeaderInfo` - Object page header
   - `@UI.LineItem` - Table columns
   - `@UI.FieldGroup` - Form sections
   - `@UI.Facets` - Object page layout
   - `@UI.SelectionFields` - Filter bar
   - `@Common.Label`, `@Common.ValueList` - Labels and dropdowns
3. **Add value helps:**
```cds
   annotate Service.Entity with {
     field @Common: {
       ValueList: {
         CollectionPath: 'ReferenceEntity',
         Parameters: [
           { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: field_ID, ValueListProperty: 'ID' }
         ]
       },
       Text: field.name,
       TextArrangement: #TextOnly
     };
   };
```
4. **Add criticality for status fields:**
```cds
   status @UI.Criticality: criticality
   virtual criticality: Integer;
```
   Implement in handler:
```javascript
   this.after('READ', 'Entity', (data) => {
     data.forEach(item => {
       item.criticality = item.status === 'approved' ? 3 : 2;
     });
   });
```
5. **Test UI:**
```bash
   cds watch
```
   Verify tables, forms, filters work correctly

**Output:** Fully annotated, production-ready UI

---

### Phase 7: Testing & Refinement
**Goal:** Ensure quality

**Steps:**
1. **Test with different users:**
   - Login as different mocked users
   - Verify authorization works
   - Check data isolation (if multi-tenant)
2. **Test workflows:**
   - Create → Edit → Delete
   - Approve/Reject actions
   - Draft handling (if enabled)
3. **Add automated tests** (`test/*.test.js`):
```javascript
   const cds = require('@sap/cds/lib');
   const { GET, POST, expect } = cds.test(__dirname + '/..');
   
   describe('Service Tests', () => {
     it('should return data', async () => {
       const { data } = await GET('/service/Entity', {
         auth: { username: 'admin' }
       });
       expect(data.value).to.be.an('array');
     });
   });
```
4. **Document in README.md:**
   - Project structure
   - How to run locally
   - User credentials
   - API endpoints

**Output:** Tested, documented application

---

### Phase 8: Cloud Deployment (USE: sap-cap-deployment)
**Goal:** Deploy to SAP BTP Cloud Foundry

**Steps:**
1. **Read the skill:** See `.ai/sap-cap-deployment.md`
2. **Install deployment tools:**
```bash
   npm install -g mbt
   cf install-plugin multiapps
```
3. **Add cloud configuration:**
```bash
   cds add mta
   cds add xsuaa
   cds add hana
```
4. **Create AppRouter** (`app/router/`):
   - `package.json` with `@sap/approuter`
   - `xs-app.json` with route configuration
5. **Build MTA archive:**
```bash
   mbt build
```
6. **Deploy to BTP:**
```bash
   cf login -a <api-endpoint>
   cf deploy mta_archives/<app>_1.0.0.mtar
```
7. **Post-deployment:**
   - Assign role collections to users in BTP Cockpit
   - Verify app is accessible
   - Check service bindings with `cf services`

**Output:** Application deployed and accessible on SAP BTP

---

## Execution Instructions for Claude

When user requests full-stack SAP development:

1. **Start with Phase 1** - Ask clarifying questions
2. **After user provides requirements, execute phases sequentially:**
   - Always read the relevant skill file from `.ai/` folder FIRST
   - Complete each phase fully before moving to next
   - Show progress: "✅ Phase 2 complete - Backend foundation ready"
3. **After each phase, ask:**
   - "Should I proceed to Phase X?"
   - OR show what was created and wait for feedback
4. **Use bash tool for:**
   - `cds init`
   - Creating files
   - Running `cds watch`
5. **Create files in correct locations:**
   - Domain model: `db/schema.cds`
   - Services: `srv/*-service.cds` + `srv/*-service.js`
   - Status flows: `srv/*-flows.cds` (December 2025)
   - Constraints: `srv/*-constraints.cds` (December 2025)
   - Authorization: `srv/access-control.cds`
   - Annotations: `app/*/annotations.cds` (auto-loaded from app/* subfolders)
   - Data: `db/data/*.csv`

**Note (December 2025):** CDS now auto-loads all `.cds` files from `app/` subfolders - no manual imports needed!

---

## Example Invocation

**User says:**
> "Build me a complete time tracking app with CAP backend and Fiori frontend"

**Claude responds:**
> I'll guide you through building a complete SAP CAP + Fiori time tracking application. Let me start by understanding your requirements:
> 
> **Phase 1: Requirements Gathering**
> 1. Who are the main users? (e.g., Employees, Managers, Admins)
> 2. What should employees be able to do?
> 3. What approval workflow do you need?
> 4. Do you need reporting/analytics?
> 5. Should it support multiple languages?
> 6. Is this for one company or multiple tenants?
>
> Once you answer these, I'll proceed with Phase 2 (Backend Foundation).

---

## Key Principles

1. **Always read skill files FIRST** - Read the relevant `.ai/*.md` file
2. **Follow CAP best practices** - `cds init`, aspects, associations
3. **Use declarative features** - `@flow.status` for state machines, `@assert` for validation (December 2025)
4. **Separate concerns** - flows, constraints, auth in separate files
5. **One phase at a time** - Don't jump ahead
6. **Show what was created** - Let user review before continuing
7. **Test after each phase** - Verify with `cds watch`
8. **Use proper file structure** - db/, srv/, app/ folders (auto-loading enabled)
9. **Mocked auth for dev** - Real auth for production

---

## Success Criteria

✅ Backend: Domain model + services + authorization working
✅ Status Flows: Declarative state transitions with `@flow.status`
✅ Validation: Declarative constraints with `@assert`
✅ Frontend: Fiori apps generated and accessible
✅ UI: Rich annotations (tables, forms, filters, value helps)
✅ Testing: Different users can login and see appropriate data
✅ Documentation: README with setup instructions
✅ Quality: Follows all SAP CAP best practices (December 2025)
✅ Deployment: Application running on SAP BTP Cloud Foundry

## How to Use It

**Option 1: Direct Invocation**
```
Use the sap-full-stack-orchestrator skill to build me a [domain] application with CAP backend and Fiori frontend
```

**Option 2: Simple Request (Claude will auto-detect)**
```
Build me a complete RMA (Return Merchandise Authorization) system with SAP CAP backend and Fiori Elements frontend
