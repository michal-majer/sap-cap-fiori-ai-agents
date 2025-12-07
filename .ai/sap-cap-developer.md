---
name: sap-cap-developer
description: Expert SAP CAP development following "The Art & Science of CAP" principles. Use when building CAP services, CDS domain models, CQL queries, event handlers, or service architectures in SAP BTP.
alwaysApply: false
---

# SAP CAP Development Agent

## Core Philosophy

**Convention over Configuration** + **Separation of Concerns** + **Functional/Relational principles**

### Principles
1. Every active thing is a service
2. Services establish interfaces (declared in CDS)
3. Services react to events (sync/async)
4. Services run queries (pushed to database)
5. Services are platform/protocol agnostic
6. Services are stateless
7. Data is passive (plain structures, not active objects)

---

## Project Initialization (CRITICAL)

**Always use `cds init`** — never manual package.json creation.
```bash
npm install -g @sap/cds-dk@latest
cds init .  # or: cds init my-project && cd my-project
```

**Add mocked auth** in package.json:
```json
{
  "cds": {
    "auth": {
      "[development]": {
        "kind": "mocked",
        "users": {
          "customer": { "password": "customer", "roles": ["authenticated-user"] },
          "admin": { "password": "admin", "roles": ["authenticated-user", "admin"] }
        }
      }
    }
  }
}
```

**Then add models:**
1. `db/schema.cds` — domain entities
2. `db/data/*.csv` — seed data
3. `srv/*-service.cds` — service definitions
4. `srv/*-service.js` — handlers
5. `srv/access-control.cds` — authorization
```bash
npm install
cds watch  # Test at http://localhost:4004
```

---

## Domain Modelling

### KISS Over Abstraction

❌ **Over-engineered:**
```cds
type Money { amount: Decimal; currency: Currency; }
entity Books { price: Money; totalprice: Money; }  // Currency matching burden
```

✅ **Simple:**
```cds
entity Books : managed {
  stock: Integer;
  price: Decimal;
  currency: Currency;  // One currency for all
}
```

### Avoid foo:Foo Anti-Pattern

❌ `type Stock : Integer; entity Books { stock : Stock; }`
✅ `entity Books { stock : Integer; }`

**Exception:** Use named types when reuse ratio is high.

### Use @sap/cds/common
```cds
using { managed, cuid, Country } from '@sap/cds/common';

entity Books : cuid, managed {
  title: localized String;
  author: Association to Authors;
}
```

---

## Separation of Concerns

### Extend Aspects Anywhere
```cds
// Extend managed to add change history
extend managed with {
  changes: Composition of many {
    key timestamp: DateTime;
    author: String;
    comment: String;
  };
}
```

### Separate Files
```cds
// srv/travel-service.cds
service TravelService { entity Travel as projection on my.Travel; }

// srv/access-control.cds
using { TravelService } from './travel-service';
annotate TravelService.Travel with @(restrict: [
  { grant: 'READ', to: 'authenticated-user' }
]);

// srv/labels.cds
annotate TravelService.Travel { BookingFee @title: '{i18n>BookingFee}'; }
```

### Empty Aspects for Reusable ACL
```cds
aspect ACL4Travels @(restrict: [
  { grant: 'READ', to: 'authenticated-user' }
]) {}
extend TravelService.Travel with ACL4Travels;
```

---

## Services

### Services as Facades (Not 1:1)

❌ **Don't:** Single mega-service exposing all entities 1:1

✅ **Do:** Use-case focused services with denormalized views
```cds
service CatalogService {
  @readonly entity ListOfBooks as projection on Books {
    ID, title, author.name as author  // Flattened
  }
}

service AdminService @(requires: 'admin') {
  entity Books as projection on db.Books;
}
```

### Projections
```cds
@readonly entity Books as projection on my.Books { *,
  author.name as author
} excluding { createdBy, modifiedBy };

entity P_Authors as projection on Authors {
  *, books[stock > 0] as availableBooks
};
```

---

## Custom Actions and Functions

### Declaration
```cds
service BookshopService {
  // Unbound
  action submitOrder(book: Books:ID, quantity: Integer) returns { status: String; };
  function getStatistics() returns { totalBooks: Integer; };

  // Bound
  entity Orders actions {
    action cancel();
    function getInvoice() returns LargeBinary;
  };
}
```

### Deep POST vs Custom Actions

**Use Deep POST when:**
- Simple nested creation, no validation
- Standard CRUD, client controls IDs
- Auto-save drafts

**Use Custom Action when:**
- Auto-generate IDs (RMA numbers, invoice numbers)
- Complex business rules (inventory, pricing)
- Explicit transaction control
- Emit events or call external services
```cds
// Custom action for complex logic
entity RMAs actions {
  action submitRMA(items: array of {...}) returns { ID: UUID; rmaNumber: String; };
}
```

### Auto-Generated Fields (NOT NULL)

❌ **Wrong — generates after INSERT:**
```javascript
this.after('CREATE', RMAs, async (data) => {
  // Too late! INSERT already failed
  await UPDATE(RMAs, data.ID).with({ rmaNumber });
});
```

✅ **Correct — generate before INSERT:**
```javascript
this.before('CREATE', RMAs, async (req) => {
  const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const seq = Math.floor(Math.random() * 99999).toString().padStart(5, '0');
  req.data.rmaNumber = `RMA-${dateStr}-${seq}`;
});
```

### Handler Implementation
```javascript
const cds = require('@sap/cds');

module.exports = class BookshopService extends cds.ApplicationService {
  init() {
    const { Books, Orders } = this.entities;

    // Unbound action
    this.on('submitOrder', async (req) => {
      const { book, quantity } = req.data;
      const bookData = await SELECT.one.from(Books, book);
      if (!bookData) return req.reject(404, `Book ${book} not found`);
      if (bookData.stock < quantity) return req.reject(409, 'Insufficient stock');

      const orderID = cds.utils.uuid();
      await INSERT.into(Orders).entries({ ID: orderID, book_ID: book, quantity });
      await UPDATE(Books, book).with({ stock: { '-=': quantity } });
      return { status: 'confirmed', orderID };
    });

    // Bound action
    this.on('cancel', Orders, async (req) => {
      const { ID } = req.params[0];
      await UPDATE(Orders, ID).with({ status: 'cancelled' });
    });

    return super.init();
  }
}
```

### Status-Changing Actions (Best Pattern)

**Pattern for state machine actions that change status:**

```javascript
module.exports = class InvoiceService extends cds.ApplicationService {
  init() {
    const { Invoices } = this.entities;

    /**
     * Action: postInvoice
     * Transition: PARKED → POSTED
     * Returns updated entity for UI refresh
     */
    this.on('postInvoice', async (req) => {
      const { params: invoices } = req;
      const { ID } = invoices.pop();

      // Validate current state
      const invoice = await SELECT.one.from(Invoices, ID);
      if (!invoice) return req.reject(404, 'Invoice not found');
      if (invoice.status_code !== 'PARKED') {
        return req.reject(409, `Can only post PARKED invoices. Current: ${invoice.status_code}`);
      }

      // Update status
      await UPDATE(Invoices, ID).set({ status_code: 'POSTED' });

      // Return updated entity (triggers UI refresh via SideEffects)
      return await SELECT.one(Invoices).where({ ID });
    });

    /**
     * Action: revertPosting
     * Transition: POSTED → PARKED
     * Returns updated entity for UI refresh
     */
    this.on('revertPosting', async (req) => {
      const { params: invoices } = req;
      const { ID } = invoices.pop();

      // Validate current state
      const invoice = await SELECT.one.from(Invoices, ID);
      if (!invoice) return req.reject(404, 'Invoice not found');
      if (invoice.status_code !== 'POSTED') {
        return req.reject(409, `Can only revert POSTED invoices. Current: ${invoice.status_code}`);
      }

      // Update status
      await UPDATE(Invoices, ID).set({ status_code: 'PARKED' });

      // Return updated entity (triggers UI refresh via SideEffects)
      return await SELECT.one(Invoices).where({ ID });
    });

    return super.init();
  }
}
```

**Key Points:**
- ✅ Extract ID from `req.params[0]` for bound actions
- ✅ Always validate current status before changing
- ✅ Return updated entity to trigger UI refresh
- ✅ Use descriptive rejection messages with current state
- ✅ Pair with `@Common.SideEffects` annotation to refresh UI automatically

---

## CQL Query Patterns

### Path Expressions & Nested Projections
```javascript
// Path expression (forward join)
await cds.ql `SELECT ID, title, author.name as author from Books`

// Nested projection (normalized)
await cds.ql `SELECT from Authors { ID, name, books { title } }`
// Returns: [{ ID: 150, name: 'Poe', books: [{ title: 'The Raven' }] }]

// Infix filters
await cds.ql `SELECT from Authors {
  ID, name, books[ID > 251] { ID, title }
} WHERE ID >= 150`

// Path in FROM (use colon)
await cds.ql `SELECT FROM Authors:books { ID, title }`

// Query as relvar (view)
const worksOfPoe = cds.ql `SELECT FROM Books WHERE author.name like '%Poe'`
await SELECT.from(worksOfPoe).where(`title like 'The %'`)
```

### Advanced Patterns
```javascript
// Expand associations
const books = await SELECT.from(Books).columns(b => {
  b.ID, b.title,
  b.author(a => { a.ID, a.name }),
  b.reviews(r => { r.rating, r.comment })
});

// Aggregations
const stats = await SELECT.from(Books).columns(
  'author_ID',
  { count: { args: ['*'], as: 'bookCount' } }
).groupBy('author_ID');

// Subqueries
const prolific = await SELECT.from(Authors).where(
  `ID in`, SELECT('author_ID').from(Books).groupBy('author_ID').having('count(*) > 5')
);
```

---

## Event Handling

### Handler Phases
```javascript
module.exports = class CatalogService extends cds.ApplicationService {
  init() {
    const { Books } = this.entities;

    // BEFORE: Validation (parallel)
    this.before('CREATE', Books, async (req) => {
      if (!req.data.title) req.error(400, 'Title required');
    });

    // ON: Core logic (sequential interceptor)
    this.on('READ', Books, async (req, next) => {
      const result = await next();
      return result;
    });

    // AFTER: Enrichment (parallel)
    this.after('READ', Books, (books) => {
      books.forEach(b => b.eligible = b.stock > 100);
    });

    return super.init();
  }
}
```

### Generic Handlers
```javascript
this.before('READ', '*', ...)     // All READ requests
this.before('*', 'Books', ...)    // All requests to Books
this.before('*', ...)             // All requests
```

### Emitting Events
```javascript
await this.emit('BookOrdered', { book: 201, quantity: 1 });  // Async event
await cats.send('SubmitOrder', { book: 201 });               // Sync request
```

---

## Error Handling

### req.error vs req.reject
```javascript
// Collects errors, continues execution
this.before('CREATE', Books, (req) => {
  if (!req.data.title) req.error(400, 'Title required', 'title');
  if (!req.data.author_ID) req.error(400, 'Author required', 'author_ID');
  // All errors returned together
});

// Throws immediately, stops execution
this.before('DELETE', Books, async (req) => {
  const book = await SELECT.one.from(Books, req.data.ID);
  if (book.stock > 0) req.reject(403, 'Cannot delete book with stock');
});
```

### HTTP Status Codes

| Code | Use |
|------|-----|
| 400 | Validation error |
| 401 | Not authenticated |
| 403 | Forbidden |
| 404 | Not found |
| 409 | Conflict |
| 422 | Unprocessable |

### Transactions
```javascript
this.on('complexOperation', async (req) => {
  const tx = cds.tx(req);
  try {
    await tx.run(INSERT.into(Orders).entries({ ... }));
    await tx.run(UPDATE(Books).with({ ... }));
    // Auto-commits on success
  } catch (err) {
    // Auto-rolls back
    req.reject(500, 'Operation failed');
  }
});
```

---

## Draft Handling

### Enable Drafts
```cds
@odata.draft.enabled
entity Books as projection on db.Books;
```

### Lifecycle Events
```javascript
this.before('NEW', Books.drafts, async (req) => {
  req.data.status = 'draft';  // Defaults for new draft
});

this.before('PATCH', Books.drafts, async (req) => {
  if (req.data.price < 0) req.error(400, 'Price must be positive');
});

this.before('SAVE', Books, async (req) => {
  if (!req.data.title) req.error(400, 'Title required for activation');
});

this.after('SAVE', Books, async (data) => {
  await this.emit('BookPublished', { book: data.ID });
});
```

### Draft Calculations for Composite Entities

**Pattern:** Parent entities with composition children (e.g., Orders with Items, RMAs with RMAItems) often need to recalculate parent totals when child items change.

**Key Issue:** During draft mode, items are in `RMAItems.drafts` but handlers may query from the active `RMAItems` table, causing calculations to fail.

**Solution:** Create a helper function that accepts an `isDraft` parameter to handle both cases:

```javascript
// Helper that works for both active and draft modes
const calculateParentTotal = async (parentId, isDraft = false) => {
  const itemsEntity = isDraft ? RMAItems.drafts : RMAItems;
  const parentEntity = isDraft ? RMAs.drafts : RMAs;

  const items = await SELECT.from(itemsEntity).where({ rma_ID: parentId });
  const total = items.reduce((sum, item) => sum + (item.totalPrice || 0), 0);
  await UPDATE(parentEntity, parentId).with({ totalAmount: total });
};

// Add handlers for BOTH draft and active modes
this.before('CREATE', RMAItems.drafts, async (req) => {
  if (req.data.quantity && req.data.unitPrice) {
    req.data.totalPrice = req.data.quantity * req.data.unitPrice;
  }
});

this.after('CREATE', RMAItems.drafts, async (data) => {
  if (data && data.rma_ID) {
    await calculateParentTotal(data.rma_ID, true);  // ← isDraft=true
  }
});

this.after('PATCH', RMAItems.drafts, async (data) => {
  if (data && data.rma_ID) {
    await calculateParentTotal(data.rma_ID, true);  // ← isDraft=true
  }
});

this.after('DELETE', RMAItems.drafts, async (data) => {
  if (data && data.rma_ID) {
    await calculateParentTotal(data.rma_ID, true);  // ← isDraft=true
  }
});

// Also add handlers for active mode (after SAVE/activation)
this.after(['CREATE', 'UPDATE'], RMAItems, async (data) => {
  if (data && data.rma_ID) {
    await calculateParentTotal(data.rma_ID, false);  // ← isDraft=false
  }
});
```

**Best Practices:**
- Always provide draft handlers (`RMAItems.drafts`) in addition to active handlers (`RMAItems`)
- Use a helper function with `isDraft` parameter to avoid duplication
- Handle CREATE, PATCH, and DELETE operations
- Test with actual draft workflows (creating parent, adding children, saving)

---

## Media Handling

### Define Media Entities
```cds
entity Attachments : cuid, managed {
  @Core.MediaType: mediaType
  @Core.ContentDisposition.Filename: filename
  content: LargeBinary;
  
  @Core.IsMediaType
  mediaType: String;
  filename: String;
  size: Integer;
}
```

### Handle Upload/Download
```javascript
this.before('PUT', Attachments, async (req) => {
  const allowedTypes = ['application/pdf', 'image/png'];
  if (!allowedTypes.includes(req.headers['content-type'])) {
    return req.reject(415, 'Unsupported media type');
  }
});

this.on('READ', Attachments, async (req, next) => {
  if (!req._.req.path.endsWith('$value')) return next();
  const { ID } = req.params[0];
  const attachment = await SELECT.one.from(Attachments, ID);
  return req.reply(attachment.content);
});
```

### Use Plugin (Production)
```bash
npm add @cap-js/attachments
```
```cds
using { Attachments } from '@cap-js/attachments';
entity Documents { attachments: Composition of many Attachments; }
```

---

## Remote Services

### Import & Configure
```bash
cds import https://api.sap.com/api/API_BUSINESS_PARTNER/overview --as API_BUSINESS_PARTNER
```
```json
{
  "cds": {
    "requires": {
      "API_BUSINESS_PARTNER": {
        "kind": "odata-v2",
        "model": "srv/external/API_BUSINESS_PARTNER",
        "[production]": {
          "credentials": { "destination": "S4HANA_CLOUD" }
        }
      }
    }
  }
}
```

### Consume
```javascript
const S4 = await cds.connect.to('API_BUSINESS_PARTNER');

this.on('READ', 'BusinessPartners', async (req) => {
  return S4.run(req.query);
});
```

### Mock
```javascript
// srv/external/API_BUSINESS_PARTNER-mock.js
module.exports = class MockBusinessPartner extends cds.Service {
  async init() {
    this.on('READ', 'A_BusinessPartner', () => [
      { BusinessPartner: '1000000', BusinessPartnerFullName: 'Test' }
    ]);
    return super.init();
  }
}
```

---

## Testing

### Basic Tests
```javascript
const cds = require('@sap/cds/lib');
const { GET, POST, expect } = cds.test(__dirname + '/..');

describe('CatalogService', () => {
  it('GET /catalog/Books', async () => {
    const { status, data } = await GET('/catalog/Books');
    expect(status).to.equal(200);
    expect(data.value).to.be.an('array');
  });

  it('POST with auth', async () => {
    const { status } = await POST('/admin/Books', {
      ID: 999, title: 'Test'
    }, { auth: { username: 'admin' } });
    expect(status).to.equal(201);
  });
});
```

---

## Authentication (Development)

### Mocked Auth
```json
{
  "cds": {
    "requires": {
      "auth": {
        "kind": "mocked",
        "users": {
          "alice": { "roles": ["Admin"] },
          "bob": { "roles": ["Manager"] },
          "*": true
        }
      }
    }
  }
}
```

### Enforce Auth on Service
```cds
service TimeTrackingService @(requires: 'authenticated-user') {
  entity Projects as projection on db.Projects;
}
```

### Authorization Patterns
```cds
// Service-level
service AdminService @(requires: 'admin') { ... }

// Entity-level
annotate AdminService.Books with @restrict: [
  { grant: 'READ', to: 'authenticated-user' },
  { grant: 'WRITE', to: 'admin' },
  { grant: 'DELETE', to: 'admin', where: 'stock = 0' }
];

// Field-level
annotate AdminService.Books with {
  costPrice @(restrict: [{ to: 'admin' }]);
};
```

---

## Multitenancy & Data Isolation

### Enable Multitenancy
```json
{
  "cds": { "requires": { "multitenancy": true } }
}
```

### Tenant Isolation (Automatic)
```javascript
this.on('READ', 'Customers', async (req) => {
  // CAP auto-filters by req.user.tenant
  return await SELECT.from('Customers');  // Only current tenant's data
});
```

### Access Tenant Info
```javascript
const tenantId = req.user.tenant;
const userId = req.user.id;
```

---

## BTP Users & Business Entities

### Pattern 1: Employee with BTP User (1:1)
```cds
entity Employees : cuid, managed {
  btpUserId: String(256) @mandatory;  // BTP email/ID
  employeeNumber: String(20);
  firstName: String(100);
  // ...
}

@assert.unique: { btpUserId: [btpUserId] }
annotate Employees with {};
```
```javascript
this.before('CREATE', 'TimeEntries', async (req) => {
  const employee = await SELECT.one.from(Employees)
    .where({ btpUserId: req.user.id });
  if (!employee) return req.reject(403, 'No employee profile found');
  req.data.employee_ID = employee.ID;
});
```

### Pattern 2: Customer with Multiple Users (1:N)
```cds
entity Customers : cuid, managed {
  name: String(200);
  users: Composition of many CustomerUsers on users.customer = $self;
}

entity CustomerUsers : cuid, managed {
  customer: Association to Customers @mandatory;
  btpUserId: String(256) @mandatory;
  role: String(50) default 'viewer';
}

@assert.unique: { btpUser: [btpUserId] }
annotate CustomerUsers with {};
```
```javascript
this.getCustomerForUser = async (userId) => {
  const user = await SELECT.one.from(CustomerUsers)
    .where({ btpUserId: userId, isActive: true });
  return user ? { customerId: user.customer_ID, role: user.role } : null;
};

this.on('READ', Orders, async (req, next) => {
  const context = await this.getCustomerForUser(req.user.id);
  if (!context) return req.reject(403, 'No customer profile');
  req.query.where({ customer_ID: context.customerId });
  return next();
});
```

---

## Localization

### Use `localized` Modifier
```cds
entity ReturnReasons : cuid {
  code: String(20) not null;                 // NOT localized
  name: localized String(100) not null;      // Localized
  description: localized String(500);
}
```

### CSV Files

**Base (English):**
```csv
db/data/app-ReturnReasons.csv
ID;code;name;description
1;DEFECTIVE;Defective;Product is defective
```

**Translations (_texts suffix):**
```csv
db/data/app-ReturnReasons_texts.csv
ID;locale;name;description
1;de;Defekt;Produkt ist defekt
1;fr;Défectueux;Le produit est défectueux
1;pl;Uszkodzony;Produkt jest uszkodzony
```

CAP returns translations based on `Accept-Language` header automatically.

---

## Initial Data Loading

### Convention: `<namespace>-<EntityName>.csv`
```
db/data/time_tracking-Employees.csv
db/data/time_tracking-Projects.csv
```

**CSV Structure:**
- Header row required (exact element names)
- `managed` fields auto-populated
- UUIDs for `cuid` keys
- Associations via foreign keys (`manager_ID`)
- Dates: ISO 8601 format
- Booleans: `true`/`false`

**Load order:** Parents before children

---

## Inline Table Editing (Fiori)

### Use FK Field, Not Association

❌ **Wrong:**
```cds
annotate Service.RMAItems with @UI.LineItem: [
  { Value: reason }  // Association, not editable
];
```

✅ **Correct:**
```cds
annotate Service.RMAItems with @UI.LineItem: [
  { Value: reason_ID }  // FK field, editable
];

reason @Common: {
  ValueList: {
    CollectionPath: 'ReturnReasons',
    Parameters: [
      {
        $Type: 'Common.ValueListParameterInOut',
        LocalDataProperty: reason_ID,
        ValueListProperty: 'ID'
      }
    ]
  },
  Text: reason.name,
  TextArrangement: #TextOnly
};
```

---

## Anti-Patterns

| ❌ Don't | ✅ Do |
|---------|------|
| Manual package.json | `cds init` always |
| Single mega-service | Use-case focused services |
| Premature microservices | Start monolithic, split late |
| Over-engineered types | Flat structures, built-in types |
| Manual FKs | Use associations |
| Hardcoded credentials | Destinations + profiles |
| Trust client customer ID | Derive from req.user |
| Assume 1 user = 1 customer | Use junction table |
| Localize code fields | Only localize display names |

---

## Quick Reference

### CQL

| Task | Pattern |
|------|---------|
| Read | `SELECT.from(Books)` |
| Filter | `.where({ stock: { '>': 0 } })` |
| Columns | `.columns('ID', 'title')` |
| Expand to-one | `.columns(b => { b.*, b.author('*') })` |
| Insert | `INSERT.into(Books).entries({ ... })` |
| Update | `UPDATE(Books, 201).with({ stock: 10 })` |
| Delete | `DELETE.from(Books).where({ ID: 201 })` |

### Handlers

| Pattern | Description |
|---------|-------------|
| `this.before('*', ...)` | All operations |
| `this.on('READ', 'Books', ...)` | READ on Books |
| `this.after('CREATE', '*', ...)` | After CREATE on any |

---

## Validation Checklist

- [ ] `cds init` used (not manual package.json)
- [ ] Namespace declared
- [ ] `using` imports
- [ ] Managed aspects applied
- [ ] Authorization annotations
- [ ] Associations (not FKs)
- [ ] Named handler functions
- [ ] `req.error()`/`req.reject()` properly used
- [ ] `async`/`await` everywhere
- [ ] `return super.init()`
- [ ] Separated concerns (auth, labels in own files)
- [ ] Test coverage

**For SaaS:**
- [ ] `btpUserId` on User/Employee entities
- [ ] Junction table for user-customer (1:N)
- [ ] Customer isolation handlers
- [ ] `localized` on user-facing text
- [ ] Translation CSV files

---

## Key Reminders

1. **Always `cds init`** — version alignment is critical
2. **Models fuel runtimes** — minimize custom code
3. **Services are stateless** — state lives in DB
4. **Data is passive** — plain JS objects
5. **Everything is extensible** — aspects extend anywhere
6. **Grow as you go** — start simple
7. **Let CAP do the work** — avoid reimplementation
8. **Link BTP users** — store btpUserId
9. **Tenant isolation automatic** — customer isolation manual
10. **Localize display** — keep codes language-independent
