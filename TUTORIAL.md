# Building Enterprise SAP Applications with AI Agents: A Step-by-Step Guide

**Learn how to build a complete SAP CAP + Fiori application using AI agents that guide you through every step of the process.**

---

## What You'll Build

In this tutorial, you'll create a **Return Merchandise Authorization (RMA) Management System** - a complete enterprise application for handling product returns with:

- ✅ **SAP CAP Backend** with proper domain modeling, services, and authorization
- ✅ **Multiple Fiori Apps** for different user roles (customers, agents, inspectors, managers)
- ✅ **Status Workflows** with declarative state transitions
- ✅ **Rich UI Features** including value helps, contact cards, and criticality colors
- ✅ **Role-Based Security** with field-level restrictions

**Time Required:** 2-3 hours (with AI agents guiding you!)

**Prerequisites:**
- Node.js 20+ installed
- SAP CAP Development Kit (`npm install -g @sap/cds-dk`)
- VSCode or Cursor with Claude Code extension
- Basic understanding of JavaScript/Node.js

---

## Architecture Overview

**What We're Building:**

```
RMA Management System
│
├── Backend (SAP CAP)
│   ├── Domain Model (6 entities: RMAs, Items, Products, Customers, Status, Reasons)
│   ├── Services (CRUD + Custom Actions)
│   ├── Business Logic (Auto-generated IDs, calculations)
│   ├── Status Flows (@flow.status)
│   └── Authorization (Role-based access)
│
└── Frontend (Fiori Elements)
    ├── Customer Portal (List Report - submit returns)
    ├── Agent Worklist (Worklist - approve/reject)
    ├── Inspector App (List Report - record inspections)
    └── Manager Dashboard (Analytical List Page - analytics)
```

**User Roles:**
- **Customer**: Submit return requests, track status
- **Agent**: Approve/reject return requests
- **Inspector**: Record inspection results when items arrive
- **Manager**: View analytics and approve refunds

---

## Part 1: Project Setup (10 minutes)

### Step 1.1: Create Project Directory

```bash
mkdir rma-management
cd rma-management
```

### Step 1.2: Initialize CAP Project

**Prompt to AI Agent:**
```
Use sap-cap-developer to initialize a new CAP project for an RMA management system
```

**What the agent will do:**
```bash
cds init --add sample
npm install
```

**Expected Output:**
```
✅ Project initialized with:
   - db/ folder for domain model
   - srv/ folder for services
   - app/ folder for Fiori apps
   - package.json with CAP dependencies
```

### Step 1.3: Configure Mocked Authentication

**Prompt:**
```
Add mocked authentication with 4 user roles: customer, agent, inspector, manager
```

The agent will add to `package.json`:
```json
{
  "cds": {
    "auth": {
      "[development]": {
        "kind": "mocked",
        "users": {
          "alice": {
            "password": "alice",
            "roles": ["authenticated-user"],
            "ID": "alice.customer@example.com"
          },
          "bob": {
            "password": "bob",
            "roles": ["authenticated-user", "agent"],
            "ID": "bob.agent@example.com"
          },
          "charlie": {
            "password": "charlie",
            "roles": ["authenticated-user", "inspector"],
            "ID": "charlie.inspector@example.com"
          },
          "dana": {
            "password": "dana",
            "roles": ["authenticated-user", "manager"],
            "ID": "dana.manager@example.com"
          }
        }
      }
    }
  }
}
```

---

## Part 2: Domain Model (30 minutes)

### Step 2.1: Design Entities

**Prompt:**
```
Use sap-cap-developer to create a domain model for RMA management with these entities:
- RMAs (main entity with auto-generated number, customer, status, items composition)
- RMAItems (products being returned with quantity, reason, condition)
- RMAStatus (code list with enum: REQUESTED, APPROVED, REJECTED, SHIPPED, RECEIVED, INSPECTED, RESOLVED, CLOSED)
- ReturnReasons (localized: defective, wrong item, changed mind, etc.)
- Products (master data with pricing)
- Customers (master data with contact information)

Use proper managed aspects, associations, and compositions following CAP best practices.
```

**What the agent creates in `db/schema.cds`:**

```cds
namespace rma;

using { cuid, managed, Currency, User, sap.common.CodeList } from '@sap/cds/common';

// Main RMA entity
entity RMAs : cuid, managed {
  rmaNumber         : String(20) not null @readonly;
  customer          : Association to Customers not null;
  rmaDate           : Date default $now;
  expectedReturnDate: Date;
  status            : Association to RMAStatus default 'REQUESTED' not null;
  items             : Composition of many RMAItems on items.rma = $self;
  totalAmount       : Decimal(15,2) @readonly;
  currency          : Currency default 'USD';
  resolutionType    : String(20);  // REFUND, REPLACEMENT, REPAIR, CREDIT
  resolutionNotes   : String(1000);
  approvedBy        : User;
  approvedDate      : Date;
  rejectionReason   : String(500);
  trackingNumber    : String(50);
  virtual criticality : Integer;
}

// RMA Line Items
entity RMAItems : cuid {
  rma              : Association to RMAs not null;
  product          : Association to Products not null;
  quantity         : Integer not null default 1;
  unitPrice        : Decimal(15,2);
  totalPrice       : Decimal(15,2);
  returnReason     : Association to ReturnReasons not null;
  condition        : String(20);  // NEW, OPENED, DAMAGED, DEFECTIVE
  inspectionNotes  : String(1000);
  inspectionDate   : Date;
  approved         : Boolean default false;
}

// Status Code List
entity RMAStatus : CodeList {
  key code : String(20) enum {
    REQUESTED  = 'REQUESTED';
    APPROVED   = 'APPROVED';
    REJECTED   = 'REJECTED';
    SHIPPED    = 'SHIPPED';
    RECEIVED   = 'RECEIVED';
    INSPECTED  = 'INSPECTED';
    RESOLVED   = 'RESOLVED';
    CLOSED     = 'CLOSED';
  };
}

// More entities: ReturnReasons, Products, Customers...
```

**Key Features Demonstrated:**
- ✅ `cuid` and `managed` aspects (auto UUID, timestamps)
- ✅ `Composition` for parent-child (RMAs → RMAItems)
- ✅ `Association` for references (RMAs → Customers)
- ✅ `CodeList` pattern with enums
- ✅ `localized` for multi-language support
- ✅ `@readonly` calculated fields
- ✅ `virtual` fields for UI

### Step 2.2: Generate Test Data

**Prompt:**
```
Generate realistic CSV test data covering all workflow states:
- 20 RMAs in various statuses
- 50 products across electronics, clothing, home goods
- 30 customers with complete contact info
- All return reasons with English and German translations
```

The agent creates CSV files in `db/data/`:
- `rma-RMAs.csv`
- `rma-RMAItems.csv`
- `rma-Products.csv`
- `rma-Customers.csv`
- `rma-ReturnReasons.csv`
- `rma-ReturnReasons_texts.csv` (translations)
- `rma-RMAStatus.csv`

### Step 2.3: Test the Model

```bash
cds watch
```

**Expected:** SQLite database created, data loaded, service running at http://localhost:4004

---

## Part 3: Service Layer (30 minutes)

### Step 3.1: Create Services

**Prompt:**
```
Use sap-cap-developer to create services:
1. RMAService - Main service with draft support, custom actions (approve, reject, markShipped, markReceived, completeInspection, resolveRMA)
2. AdminService - Master data maintenance (requires 'admin' role)

Follow the "services as facades" pattern with projections.
```

**Result in `srv/rma-service.cds`:**

```cds
using { rma } from '../db/schema';

service RMAService {
  @odata.draft.enabled
  entity RMAs as projection on rma.RMAs actions {
    action approve();
    action reject(reason: String(500));
    action markShipped(trackingNumber: String(50));
    action markReceived();
    action completeInspection();
    action resolveRMA(resolutionType: String(20), notes: String(1000));
  };

  entity RMAItems as projection on rma.RMAItems;

  @readonly entity Products as projection on rma.Products;
  @readonly entity Customers as projection on rma.Customers;
  @readonly entity ReturnReasons as projection on rma.ReturnReasons;
  @readonly entity RMAStatus as projection on rma.RMAStatus;
}

service AdminService @(requires: 'admin') {
  entity Products as projection on rma.Products;
  entity Customers as projection on rma.Customers;
  entity ReturnReasons as projection on rma.ReturnReasons;
}
```

### Step 3.2: Add Status Flows (December 2025 Feature!)

**Prompt:**
```
Use sap-cap-developer to implement @flow.status declarative state transitions for RMAs
```

**Result in `srv/rma-flows.cds`:**

```cds
using { RMAService } from './rma-service';

annotate RMAService.RMAs with @flow.status: status actions {
  approve            @from: [ #REQUESTED ]  @to: #APPROVED;
  reject             @from: [ #REQUESTED ]  @to: #REJECTED;
  markShipped        @from: [ #APPROVED ]   @to: #SHIPPED;
  markReceived       @from: [ #SHIPPED ]    @to: #RECEIVED;
  completeInspection @from: [ #RECEIVED ]   @to: #INSPECTED;
  resolveRMA         @from: [ #INSPECTED ]  @to: #RESOLVED;
};
```

**What this does:** Automatically validates status transitions and rejects invalid state changes!

### Step 3.3: Add Validation Constraints

**Prompt:**
```
Add @assert declarative validation constraints:
- expectedReturnDate must be after rmaDate
- RMAs must have at least one item
- resolutionType required when status = RESOLVED
- quantity must be between 1 and 100
```

**Result in `srv/rma-constraints.cds`:**

```cds
using { RMAService } from './rma-service';

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

### Step 3.4: Implement Business Logic

**Prompt:**
```
Create handlers in srv/rma-service.js for:
1. Auto-generate RMA numbers (format: RMA-YYYYMMDD-XXXXX)
2. Calculate totalAmount when items change
3. Set criticality based on status (REJECTED=1, REQUESTED=2, APPROVED=3)
4. Implement approve() and reject() actions
```

The agent creates the handler file with proper event handling patterns.

---

## Part 4: Authorization (20 minutes)

**Prompt:**
```
Use sap-cap-developer to create authorization rules in srv/access-control.cds:
- Customers: Read/write only their own RMAs
- Agents: Read all RMAs, write only REQUESTED status
- Inspectors: Read/write RECEIVED and INSPECTED RMAs
- Managers: Read all, no direct write (read-only analytics)
```

**Result:**

```cds
using { RMAService } from './rma-service';

// Customers see only their own RMAs
annotate RMAService.RMAs with @restrict: [
  {
    grant: ['READ', 'WRITE'],
    to: 'authenticated-user',
    where: 'customer.email = $user.id'
  },
  {
    grant: 'READ',
    to: 'agent'
  },
  {
    grant: 'WRITE',
    to: 'agent',
    where: 'status.code = ''REQUESTED'''
  }
];
```

---

## Part 5: Choose Floorplans (15 minutes)

**Prompt:**
```
Use sap-fiori-designer to help me choose floorplans for:
1. Customers submitting and tracking returns
2. Agents processing approval requests
3. Inspectors recording inspection results
4. Managers viewing analytics
```

**Agent Recommendation:**

| User Role | Floorplan | Reasoning |
|-----------|-----------|-----------|
| **Customers** | List Report Object Page | Browse own returns, create new, view details |
| **Agents** | Worklist | Process tasks sequentially with approve/reject actions |
| **Inspectors** | List Report Object Page | Browse received items, record inspection |
| **Managers** | Analytical List Page | KPIs, charts, visual filters for insights |

---

## Part 6: Generate Fiori Apps (30 minutes)

### Step 6.1: Generate Customer Portal

**Prompt:**
```
Use sap-fiori-scaffolder to generate a List Report Object Page app named 'customer-portal' for RMAService.RMAs entity
```

The agent generates the app with proper manifest configuration.

### Step 6.2: Generate Agent Worklist

**Prompt:**
```
Generate a Worklist app named 'agent-worklist' for RMAService.RMAs with focus on pending approvals
```

### Step 6.3: Generate Inspector App

**Prompt:**
```
Generate a List Report app named 'inspector-app' for RMAService.RMAs filtered to received status
```

### Step 6.4: Generate Manager Dashboard

**Prompt:**
```
Generate an Analytical List Page app named 'manager-dashboard' for RMAService.RMAs with analytics focus
```

---

## Part 7: Add UI Annotations (45 minutes)

### Step 7.1: Customer Portal Annotations

**Prompt:**
```
Use sap-fiori-elements-developer to add annotations for customer portal:
- Table columns: RMA number, date, status (with criticality colors), total amount
- Filter bar: status, date range
- Object page sections: items table, customer info (as contact card), resolution details
- Value help for products when adding items
```

The agent creates `app/customer-portal/annotations.cds` with comprehensive annotations.

### Step 7.2: Agent Worklist Annotations

**Prompt:**
```
Add annotations for agent worklist:
- Tabs: Pending (REQUESTED), Approved, Rejected
- Line item actions: approve, reject buttons
- KPI headers showing counts per tab
- Criticality colors: red=rejected, yellow=pending, green=approved
```

**Key Annotations Added:**

```cds
annotate RMAService.RMAs with @UI: {
  LineItem: [
    { Value: rmaNumber },
    { Value: customer.contactName },
    { Value: rmaDate },
    {
      Value: status_code,
      Criticality: criticality  // Color coding!
    },
    { Value: totalAmount },
    {
      $Type: 'UI.DataFieldForAction',
      Action: 'RMAService.approve',
      Label: 'Approve'
    },
    {
      $Type: 'UI.DataFieldForAction',
      Action: 'RMAService.reject',
      Label: 'Reject'
    }
  ],
  SelectionPresentationVariant #Pending: {
    SelectionVariant: {
      SelectOptions: [{
        PropertyName: status_code,
        Ranges: [{ Sign: #I, Option: #EQ, Low: 'REQUESTED' }]
      }]
    }
  }
};
```

### Step 7.3: Inspector & Manager Apps

Similar prompts for inspector app and manager dashboard, adding charts and visual filters to the ALP.

---

## Part 8: Testing (30 minutes)

**Prompt:**
```
Use sap-cap-developer to create tests:
1. Service test: Create RMA, add items, approve, verify status
2. Authorization test: Verify customers can't see other customers' RMAs
3. Status flow test: Verify invalid transitions are rejected
```

The agent creates test files in `test/` directory.

**Run tests:**
```bash
npm test
```

---

## Part 9: Run & Verify (15 minutes)

### Start the Application

```bash
cds watch
```

### Test Each User Role

**As Customer (alice / alice):**
1. Go to http://localhost:4004
2. Create new RMA
3. Add products using value help
4. Submit → Status becomes "Requested"

**As Agent (bob / bob):**
1. Open Agent Worklist
2. See pending RMAs
3. Approve one → Status becomes "Approved" (green)
4. Reject one with reason → Status becomes "Rejected" (red)

**As Inspector (charlie / charlie):**
1. Open Inspector App
2. Mark RMA as received
3. Add inspection notes
4. Complete inspection

**As Manager (dana / dana):**
1. Open Manager Dashboard
2. View KPIs and charts
3. Filter by return reason
4. Export data

---

## What You've Built

✅ **Complete SAP CAP Backend**
- 6 entities with proper relationships
- Services with custom actions
- Declarative status flows (@flow.status)
- Declarative validation (@assert)
- Role-based authorization
- Business logic handlers
- Comprehensive test suite

✅ **4 Professional Fiori Apps**
- Customer portal (List Report)
- Agent worklist (Worklist with tabs)
- Inspector app (List Report)
- Manager dashboard (Analytical List Page)

✅ **Production-Ready Features**
- Value helps everywhere
- Contact cards for customer info
- Criticality color coding
- Multi-language support
- Draft editing workflows
- Responsive UI

---

## Key Takeaways

**What Made This Fast:**
1. **AI Agents handled boilerplate** - No need to remember annotation syntax
2. **Best practices built-in** - Agents follow SAP CAP conventions
3. **Declarative features** - @flow.status and @assert reduce code
4. **Metadata-driven UI** - Annotations generate rich Fiori apps

**Skills You Can Apply:**
- Domain modeling with CAP
- Service-oriented architecture
- Authorization patterns
- Fiori floorplan selection
- UI annotations
- Status workflows

---

## Next Steps

### Deploy to SAP BTP

**Prompt:**
```
Use sap-cap-deployment to deploy this application to SAP BTP Cloud Foundry
```

The agent will guide you through:
- MTA configuration
- XSUAA setup
- HANA Cloud connection
- Deployment process

### Add More Features

Try these prompts:
```
Add email notifications when RMAs are approved
```

```
Create a custom action to generate PDF reports
```

```
Add file upload for photos of returned items
```

### Learn More

- **Full Agent Documentation**: See `.ai/` folder in the repository
- **SAP CAP Documentation**: https://cap.cloud.sap
- **Fiori Elements**: https://ui5.sap.com/fiori-elements

---

## About the AI Agents

This tutorial used 4 of the 6 available AI agents:

1. **sap-cap-developer** - Backend development
2. **sap-fiori-designer** - Floorplan selection
3. **sap-fiori-scaffolder** - App generation
4. **sap-fiori-elements-developer** - UI annotations

**Also available:**
- **sap-cap-deployment** - Deploy to SAP BTP
- **sap-full-stack-orchestrator** - Guided end-to-end development

**Get the Agents:**
- Repository: https://github.com/[your-repo]/sap-cap-fiori-ai-agents
- Clone and use in VSCode/Cursor with Claude Code extension
- Skills automatically available in `.github/skills/`

---

## Conclusion

You've just built a complete enterprise SAP application in 2-3 hours using AI agents as your guide. The same application would typically take 2-3 weeks to build manually!

**The power of AI-assisted development:**
- Faster iteration cycles
- Built-in best practices
- Less boilerplate
- More time for business logic

Try building your own application with these agents!

---

**Questions or feedback?** Open an issue in the repository or contact [your contact info]

**Found this helpful?** ⭐ Star the repository and share with your team!
