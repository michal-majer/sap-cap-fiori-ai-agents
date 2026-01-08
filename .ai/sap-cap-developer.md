---
name: sap-cap-developer
description: Expert SAP CAP development following "The Art & Science of CAP" principles. Use when building CAP services, CDS domain models, CQL queries, event handlers, or service architectures in SAP BTP. Updated for December 2025 CAP release.
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

### Auto-Loading from app/* Subfolders (December 2025)

CDS now automatically loads all `.cds` files from `app/` and its subfolders. No more `app/index.cds` with manual imports needed:

```
app/
├── travels/
│   ├── annotations.cds    # Auto-loaded
│   └── labels.cds         # Auto-loaded
├── bookings/
│   └── annotations.cds    # Auto-loaded
└── common/
    └── value-helps.cds    # Auto-loaded
```

Disable with: `cds.folders.apps: false`

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

### Status Entities with CodeList
```cds
entity TravelStatus : sap.common.CodeList {
  key code : String(1) enum {
    Open     = 'O';
    InReview = 'P';
    Blocked  = 'B';
    Accepted = 'A';
    Rejected = 'X';
  }
}

entity Travels : managed {
  key ID     : Integer default 0 @readonly;
  Status     : Association to TravelStatus default 'O';
  // ...
}
```

### Custom Types
```cds
type Price : Decimal(9,4);
type Percentage : Integer @assert.range: [1,100];
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

### Separate Files Pattern
```
srv/
├── travel-service.cds      # Service definition
├── travel-service.js       # Handler implementation
├── travel-flows.cds        # Status transition flows
├── travel-constraints.cds  # Declarative constraints
├── access-control.cds      # Authorization
└── annotations/
    └── labels.cds          # i18n labels
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

### Service with Actions
```cds
service TravelService {
  entity Travels as projection on db.Travels actions {
    action createTravelByTemplate() returns Travels;
    action acceptTravel();
    action rejectTravel();
    action reopenTravel();
    action deductDiscount( percent: Percentage not null ) returns Travels;
  }

  @readonly entity Flights as projection on dbx.Flights;
  @readonly entity Currencies as projection on sap.common.Currencies;
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

## Status-Transition Flows (December 2025 - Gamma)

Status-transition flows ensure transitions are explicitly modeled, validated, and executed in a controlled and reliable way, **eliminating the need for custom status-changing code**.

### Modeling Status Flows

```cds
using { TravelService } from './travel-service';

annotate TravelService.Travels with @flow.status: Status actions {
  deductDiscount  @from: [ #Open ];                           // Restricted to Open
  acceptTravel    @from: [ #Open ]     @to: #Accepted;
  rejectTravel    @from: [ #Open ]     @to: #Rejected;
  reopenTravel    @from: [ #Rejected, #Accepted ] @to: #Open;
}
```

### Annotations

| Annotation | Purpose |
|------------|---------|
| `@flow.status: element` | Entity-level: designates which element is flow-controlled |
| `@from: [ #State1, #State2 ]` | Action allowed only from these states |
| `@to: #TargetState` | Automatically sets status after action succeeds |
| `@to: $flow.previous` | Returns to previous state (CAP tracks history) |

### Status Element Requirements

The designated status element must be either:

**Option 1: Direct enum**
```cds
entity Travels {
  @readonly Status : TravelStatusCode default 'O';
}

type TravelStatusCode : String enum {
  Open     = 'O';
  Accepted = 'A';
  Rejected = 'X';
}
```

**Option 2: Association to CodeList with `code` enum**
```cds
entity Travels {
  @readonly Status : Association to TravelStatus default 'O';
}

entity TravelStatus : sap.common.CodeList {
  key code : String enum { Open='O'; Accepted='A'; Rejected='X'; }
}
```

### What CAP Provides Out-of-the-Box

**Generic handlers eliminate custom code:**
- `@from` validation: Rejects action if current state not in allowed list (HTTP 409)
- `@to` transition: Automatically updates status element after action succeeds
- `$flow.previous` tracking: Maintains history for "undo" scenarios

**Fiori UI integration:**
- `Core.OperationAvailable` annotations auto-generated (enable/disable buttons)
- `Common.SideEffects` annotations auto-generated (refresh displayed data)

### When to Add Custom Handlers

Custom handlers are only needed for **additional business fields**, not status changes.

**CRITICAL: Use `before` handlers, NOT `on` handlers!**

`@flow.status` provides its own `on` handler that performs the status transition. If you use `this.on()`, you **replace** this handler and the status won't change. Always use `this.before()`:

```javascript
// ✅ Correct: Use 'before' handler to set business fields
this.before('approve', 'RMAs', async (req) => {
    const { ID } = req.params[0];
    await UPDATE(RMAs, ID).with({
        approvedBy: req.user.id,
        approvedDate: new Date().toISOString().split('T')[0]
    });
    // @flow.status generic 'on' handler runs AFTER this and sets status_code
});
```

❌ **Wrong: Using `on` replaces @flow.status handler:**
```javascript
// DON'T DO THIS - you're replacing the @flow.status handler!
this.on('approve', 'RMAs', async (req) => {
    // Status will NOT change because you replaced the generic handler!
    await UPDATE(RMAs, ID).with({ approvedBy: req.user.id });
});
```

❌ **Also Wrong: Don't manually set status:**
```javascript
// DON'T DO THIS - @flow.status handles it!
await UPDATE(RMAs, ID).with({
    status_code: 'APPROVED'  // REDUNDANT if using @flow.status
});
```

### Returning to Previous State

Use `$flow.previous` for "unblock" or "reopen" scenarios:

```cds
annotate TravelService.Travels with @flow.status: Status actions {
  blockTravel     @from: [#Open, #InReview]  @to: #Blocked;
  unblockTravel   @from: #Blocked            @to: $flow.previous;  // Returns to Open or InReview
}
```

### Current Limitations

- **Draft mode**: All actions disabled while in draft state; transitions only on active entities
- **CRUD operations**: Cannot be flow-controlled (only bound actions)

### Testing Status Flows

```javascript
const { GET, POST, expect } = cds.test(__dirname + '/..');

it('rejects invalid transition', async () => {
  const { error } = await POST('/odata/v4/travel/Travels(ID=1)/acceptTravel', {})
  expect(error).to.contain('requires "Status_code" to be')
})

it('tracks transitions', async () => {
  await POST('/odata/v4/travel/Travels(ID=1)/blockTravel', {})
  const { data } = await GET('/odata/v4/travel/Travels(ID=1)')
  expect(data.transitions_).to.have.length.greaterThan(0)
})
```

---

## Declarative Constraints (December 2025 - Gamma)

Use `@assert` annotation with CDS Expression Language (CXL) for validation:

```cds
using { TravelService } from './travel-service';

annotate TravelService.Travels with {

  Description @assert: (case
    when length(Description) < 3 then 'Description too short'
  end);

  Agency @mandatory @assert: (case
    when not exists Agency then 'Agency does not exist'
  end);

  Customer @assert: (case
    when Customer is null then 'Customer must be specified'
    when not exists Customer then 'Customer does not exist'
  end);

  BeginDate @mandatory @assert: (case
    when EndDate < BeginDate then 'ASSERT_BEGINDATE_BEFORE_ENDDATE'
    when exists Bookings [Flight.date < Travel.BeginDate]
      then 'ASSERT_BOOKINGS_IN_TRAVEL_PERIOD'
  end);

  EndDate @mandatory @assert: (case
    when EndDate < BeginDate then 'ASSERT_ENDDATE_AFTER_BEGINDATE'
    when exists Bookings [Flight.date > Travel.EndDate]
      then 'ASSERT_BOOKINGS_IN_TRAVEL_PERIOD'
  end);

  BookingFee @assert: (case
    when BookingFee < 0 then 'ASSERT_BOOKING_FEE_NON_NEGATIVE'
  end);

}
```

### Cross-Entity Validation
```cds
annotate TravelService.Bookings with {

  Travel @mandatory;

  Flight @mandatory {
    date @assert: (case
      when date not between $self.Travel.BeginDate and $self.Travel.EndDate
        then 'ASSERT_BOOKING_IN_TRAVEL_PERIOD'
    end);
  };

  Currency @assert: (case
    when Currency != Travel.Currency then 'ASSERT_BOOKING_CURRENCY_MATCHES_TRAVEL'
  end);

  BookingDate @assert: (case
    when BookingDate > Travel.EndDate then 'ASSERT_NO_BOOKINGS_AFTER_TRAVEL'
  end);

}
```

**Key Features:**
- `case when ... then 'error message' end` — Return error message when condition is true
- `exists` / `not exists` — Check association existence
- `$self` — Reference current entity in nested contexts
- `between` — Range check
- String return = error message (i18n keys supported)

---

## API Export (December 2025 - Beta)

Create reusable API client packages from CDS service definitions:

```bash
# Generate API package
cds export srv/data-service.cds

# Publish to npm registry
npm publish ./apis/data-service
```

**Consumers:**
```bash
npm add @capire/xflights-data
```

The generated package:
- Contains lossless CDS API models
- Applies CAP plugin techniques for plug & play
- No additional configuration required in consuming apps

---

## Direct CRUD on Draft-enabled Entities (December 2025 - Beta)

Enable direct CRUD requests without draft sequence (EDIT → PATCH → SAVE):

```json
{
  "cds": {
    "fiori": {
      "direct_crud": true
    }
  }
}
```

**Usage:**
```http
POST {{server}}/odata/v4/travel/Travels
{ "ID": 4711 }

PUT {{server}}/odata/v4/travel/Travels(ID=4711)
{ "Description": "Fun times!" }
```

- `IsActiveEntity` defaults to `true` and can be omitted
- POST creates the active entity directly
- Works seamlessly with existing implementations

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

### Auto-Generated Fields (NOT NULL)

❌ **Wrong — generates after INSERT:**
```javascript
this.after('CREATE', RMAs, async (data) => {
  await UPDATE(RMAs, data.ID).with({ rmaNumber });  // Too late!
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

---

## Enterprise Handler Patterns

### Modular Service Class Structure
```javascript
const cds = require('@sap/cds')

class TravelService extends cds.ApplicationService {

  async init() {
    this.service_integration()    // External system sync
    this.generate_primary_keys()  // ID sequence generation
    this.deduct_discounts()       // Business actions
    this.update_totals()          // Calculated fields
    this.status_flows()           // State enforcement
    this.data_export()            // CSV/JSON streaming
    return super.init()
  }

  // Each method encapsulates related handlers
  generate_primary_keys() {
    const { Travels, Bookings } = this.entities

    this.before('CREATE', Travels, async (req) => {
      let { id } = await SELECT.one `max(ID) as id` .from(Travels)
      req.data.ID = ++id
    })

    this.before('NEW', Travels.drafts, async req => {
      const [ active, draft ] = await Promise.all([
         SELECT.one(`max(ID) as maxID`).from(Travels),
         SELECT.one(`max(ID) as maxID`).from(Travels.drafts)
      ])
      req.data.ID = Math.max(draft?.maxID, active?.maxID) + 1
    })

    this.before('NEW', Bookings.drafts, async (req) => {
      let { id } = await SELECT.one `max(Pos) as id` .from(Bookings.drafts).where(req.data)
      req.data.Pos = ++id
    })
  }

  // ... other methods
}

module.exports = { TravelService }
```

### Native SQL for Efficient Totals
```javascript
update_totals() {
  const { Travels, Bookings, 'Bookings.Supplements': Supplements } = this.entities

  // Native SQL UPDATE, prepared once and reused
  const UpdateTotals = `UPDATE ${Travels.drafts} as t SET TotalPrice =
    coalesce(BookingFee,0)
    + (SELECT coalesce(sum(FlightPrice),0) from ${Bookings.drafts} where Travel_ID = t.ID)
    + (SELECT coalesce(sum(Price),0) from ${Supplements.drafts} where up__Travel_ID = t.ID)
  WHERE ID = ?`

  this.on('PATCH',  Travels.drafts,     (..._) => update_totals(..._, 'BookingFee'))
  this.on('PATCH',  Bookings.drafts,    (..._) => update_totals(..._, 'FlightPrice'))
  this.on('PATCH',  Supplements.drafts, (..._) => update_totals(..._, 'Price'))
  this.on('DELETE', Bookings.drafts,    (..._) => update_totals(..._, 'ID'))
  this.on('DELETE', Supplements.drafts, (..._) => update_totals(..._, 'ID'))

  async function update_totals(req, next, ...fields) {
    if (!fields.some(field => field in req.data)) return next()
    await next()
    const { ID: TravelID } =
      req.target === Supplements.drafts ? await SELECT.one `up_.Travel.ID as ID`.from(req.subject) :
      req.target === Bookings.drafts ? await SELECT.one `Travel.ID as ID`.from(req.subject) :
      req.target === Travels.drafts ? req.data : cds.error(`No travel found for ${req.subject}`)
    await cds.run(UpdateTotals, [TravelID])
  }
}
```

### Draft Lock Enforcement
```javascript
status_flows() {
  const { Travels, Bookings } = this.entities
  const { acceptTravel, rejectTravel } = Travels.actions
  const { Open } = this.StatusCodes

  // Prevent adding bookings to non-open travels
  this.before('NEW', Bookings.drafts, async (req) => {
    let { status } = await SELECT `Status_code as status`.from(Travels.drafts, req.data.to_Travel_ID)
    if (status !== Open) req.reject(409, `Cannot add new bookings to travels which are not open.`)
  })

  // Prevent accepting/rejecting locked travels
  this.before([acceptTravel, rejectTravel], [Travels, Travels.drafts], async req => {
    const draft = await SELECT.one(Travels.drafts, req.params[0])
      .columns `DraftAdministrativeData.InProcessByUser as owner`
    if (!draft || draft.owner === req.user.id && req.target.isDraft) return
    else req.reject(423, `The travel is locked by ${draft.owner}.`)
  })
}

// Derive status codes from enum definitions
get StatusCodes() {
  const { TravelStatus } = this.entities, { code } = TravelStatus.elements
  return super.StatusCodes = Object.fromEntries(Object.entries(code.enum)
    .map(([k, v]) => [k, v.val])
  )
}
```

### Data Export (Streaming)
```javascript
data_export() {
  const { Travels, TravelsExport } = this.entities
  const { exportCSV, exportJSON } = this.actions
  const { Readable } = require('stream')

  this.on(exportCSV, async req => {
    let query = SELECT.localized(TravelsExport.projection).from(Travels)
    let stream = Readable.from(async function*() {
      yield Object.keys(query.elements).join(';') + '\n'
      for await (const row of query)
        yield Object.values(row).join(';') + '\n'
    }())
    return req.reply(stream, { filename: 'Travels.csv' })
  })

  this.on(exportJSON, async req => {
    let query = SELECT.localized(TravelsExport.projection).from(Travels)
    let stream = await query.stream()
    return req.reply(stream, { filename: 'Travels.json' })
  })
}
```

### Service Integration with Outbox
```javascript
async service_integration() {
  const xflights = await cds.connect.to('sap.capire.flights.data').then(cds.outboxed)
  const { Flights, Travels } = this.entities

  // Receive updates from external service
  xflights.on('Flights.Updated', async msg => {
    const { flightNumber, flightDate, occupiedSeats } = msg.data
    await UPDATE(Flights, { flightNumber, flightDate }).with({ occupiedSeats })
  })

  // Inform external service about bookings
  this.after('SAVE', Travels, ({ Bookings=[] }) => Promise.all(
    Bookings.map(({ flightNumber, flightDate }) => xflights.send('BookingCreated', {
      flightNumber, flightDate
    }))
  ))
}
```

---

## Status-Changing Actions (Best Pattern)

```javascript
/**
 * Action: postInvoice
 * Transition: PARKED → POSTED
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
```

**Key Points:**
- Extract ID from `req.params[0]` for bound actions
- Always validate current status before changing
- Return updated entity to trigger UI refresh
- Pair with `@Common.SideEffects` annotation

---

## CQL Query Patterns

### Path Expressions & Nested Projections
```javascript
// Path expression (forward join)
await cds.ql `SELECT ID, title, author.name as author from Books`

// Nested projection (normalized)
await cds.ql `SELECT from Authors { ID, name, books { title } }`

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
| 423 | Locked |

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

**Pattern:** Parent entities with composition children need to recalculate totals when children change.

**Key Issue:** During draft mode, items are in `.drafts` table but queries may hit active table.

**Solution:** Helper function with `isDraft` parameter:

```javascript
const calculateParentTotal = async (parentId, isDraft = false) => {
  const itemsEntity = isDraft ? RMAItems.drafts : RMAItems;
  const parentEntity = isDraft ? RMAs.drafts : RMAs;

  const items = await SELECT.from(itemsEntity).where({ rma_ID: parentId });
  const total = items.reduce((sum, item) => sum + (item.totalPrice || 0), 0);
  await UPDATE(parentEntity, parentId).with({ totalAmount: total });
};

// Draft mode handlers
this.after('CREATE', RMAItems.drafts, async (data) => {
  if (data?.rma_ID) await calculateParentTotal(data.rma_ID, true);
});

this.after('PATCH', RMAItems.drafts, async (data) => {
  if (data?.rma_ID) await calculateParentTotal(data.rma_ID, true);
});

this.after('DELETE', RMAItems.drafts, async (data) => {
  if (data?.rma_ID) await calculateParentTotal(data.rma_ID, true);
});

// Active mode handlers (after SAVE)
this.after(['CREATE', 'UPDATE'], RMAItems, async (data) => {
  if (data?.rma_ID) await calculateParentTotal(data.rma_ID, false);
});
```

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

### Use Plugin (Recommended)
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

### Testing Status Flows
```javascript
describe('Status Transition Flows', () => {
  it('rejects invalid transitions', async () => {
    const { error } = await POST('/odata/v4/travel/Travels(ID=1)/acceptTravel', {})
    expect(error).to.contain('requires "Status_code" to be')
  })

  it('tracks transitions', async () => {
    await POST('/odata/v4/travel/Travels(ID=1)/blockTravel', {})
    const { data: travel } = await GET('/odata/v4/travel/Travels(ID=1)')
    expect(travel.transitions_).to.have.length.greaterThan(0)
  })
})
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
```

---

## Deprecated APIs (December 2025)

The following will be removed in CAP 10:

| Deprecated | Use Instead |
|------------|-------------|
| `srv.entities()` | `srv.entities` / `cds.entities()` |
| `srv.types()` | `srv.types` |
| `srv.events()` | `srv.events` |
| `srv.actions()` | `srv.actions` |
| `CatalogService['Books.texts']` | `CatalogService.Books.texts` |

Enable new behavior early: `cds.features.compat_texts_entities: false`

---

## Sample Data (CSV Files)

### UUID Format for `cuid` Entities (CRITICAL)

When using `cuid` aspect (which uses UUID keys), CSV sample data **MUST** use valid UUID format with hex-only characters (0-9, a-f).

❌ **Wrong — Invalid UUIDs:**
```csv
ID;name
r1001;Product A          # 'r' is not a hex character!
c2001;Customer B         # 'c' is not a hex character!
p3001;RMA C             # 'p' is not a hex character!
```

❌ **Still Wrong — Letter prefix not hex:**
```csv
ID;name
r1001001-0000-4000-8000-000000000001;Product A   # 'r' is NOT valid hex!
```

✅ **Correct — Hex-only UUIDs:**
```csv
ID;name
a1001001-0000-4000-a000-000000000001;Product A   # 'a' IS valid hex (0-9, a-f)
31001001-0000-4000-a000-000000000001;Customer B  # Numbers are valid
11001001-0000-4000-a000-000000000001;RMA C       # Numbers are valid
```

**Recommended Convention for Sample Data UUIDs:**
- Use digit prefix for entity type identification: `1` for main entities, `2` for items, `3` for customers, `a` for products
- Format: `{type}{sequence}-0000-4000-a000-{padding}`
- Example: `a1001001-0000-4000-a000-000000000001` (product #1)

**Why this matters:**
- OData V4 strictly validates UUID format
- Navigation to Object Pages fails with "Invalid value" error
- The error is cryptic: `Invalid value: r1001` without explaining UUID validation

---

## Reserved Action Names (CRITICAL)

**Never name custom actions with names that conflict with base class methods.**

❌ **Wrong — Conflicts with `cds.ApplicationService` methods:**
```cds
entity Orders actions {
  action reject();       // CONFLICTS with ApplicationService.reject()!
  action error();        // CONFLICTS with error handling!
  action emit();         // CONFLICTS with event emission!
}
```

Warning message:
```
[cds] - WARNING: custom action 'reject()' conflicts with method in base class.
Cannot add typed method for custom action 'reject' to service impl of 'MyService',
as this would shadow equally named method in service base class 'ApplicationService'.
```

✅ **Correct — Use entity-prefixed names:**
```cds
entity Orders actions {
  action rejectOrder();      // Clear, no conflict
  action cancelOrder();      // Clear, no conflict
  action approveOrder();     // Clear, no conflict
}

entity RMAs actions {
  action rejectRMA(reason: String);   // Clear, entity-prefixed
  action approveRMA();
}
```

**Reserved names to avoid for actions:**
- `reject` — Used by `req.reject()` for error handling
- `error` — Used by `req.error()` for validation
- `emit` — Used for event emission
- `send` — Used for synchronous requests
- `run` — Used for query execution
- `read` — Used for entity reading

**Best Practice:** Always prefix action names with the entity name for clarity:
- `approve` → `approveTravel`, `approveRMA`, `approveOrder`
- `reject` → `rejectTravel`, `rejectRMA`, `rejectOrder`
- `cancel` → `cancelBooking`, `cancelOrder`

---

## Anti-Patterns

| ❌ Don't | ✅ Do |
|---------|------|
| Manual package.json | `cds init` always |
| Single mega-service | Use-case focused services |
| Premature microservices | Start monolithic, split late |
| Over-engineered types | Flat structures, built-in types |
| Manual FKs | Use associations |
| Manual status validation | Use `@flow.status` |
| Imperative constraints | Use `@assert` annotations |
| Hardcoded credentials | Destinations + profiles |
| Trust client customer ID | Derive from req.user |
| Non-hex UUID sample data | Use hex-only UUIDs (0-9, a-f) |
| Action names like `reject` | Use `rejectEntity` pattern |

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
- [ ] Managed aspects applied (`cuid`, `managed`)
- [ ] Authorization annotations
- [ ] Associations (not FKs)
- [ ] `@flow.status` for state machines
- [ ] `@assert` for validation constraints
- [ ] Named handler functions
- [ ] `req.error()`/`req.reject()` properly used
- [ ] `async`/`await` everywhere
- [ ] `return super.init()`
- [ ] Separated concerns (flows, constraints, auth in own files)
- [ ] Test coverage

---

## Key Reminders

1. **Always `cds init`** — version alignment is critical
2. **Models fuel runtimes** — minimize custom code
3. **Services are stateless** — state lives in DB
4. **Data is passive** — plain JS objects
5. **Use `@flow.status`** — declarative state machines
6. **Use `@assert`** — declarative validation
7. **Separate concerns** — flows, constraints, auth in own files
8. **Grow as you go** — start simple
9. **Let CAP do the work** — avoid reimplementation
10. **Test status flows** — verify transitions work as expected
