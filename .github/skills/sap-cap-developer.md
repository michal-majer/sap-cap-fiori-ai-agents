---
name: sap-cap-developer
description: Expert SAP CAP development agent for CDS models, services, handlers, and authorization
---

# SAP CAP Developer Skill

This skill provides expert guidance for SAP CAP backend development following "The Art & Science of CAP" principles.

## When to Use

- Creating CDS domain models with entities, associations, and compositions
- Defining services with projections and custom actions
- Implementing business logic handlers (event handlers, calculated fields)
- Setting up authorization rules (@restrict, field-level security)
- Using December 2025 features: @flow.status (state machines), @assert (validation)
- Writing CQL queries and working with draft-enabled entities
- Testing CAP services

## How to Invoke

From your IDE (VSCode/Cursor with Claude Code extension):

```
Help me create a CAP domain model for an RMA (Return Merchandise Authorization) system
```

Or more specific requests:
```
Use sap-cap-developer to implement status transition flows with @flow.status
```

```
Create a CAP service with custom actions for approve and reject operations
```

## Core Principles

**Convention over Configuration**
- Always use `cds init` for new projects
- Follow standard folder structure (db/, srv/, app/)
- Use managed aspects (cuid, managed)

**Separation of Concerns**
- Domain entities in db/schema.cds
- Service definitions in srv/*-service.cds
- Status flows in srv/*-flows.cds (separate file)
- Constraints in srv/*-constraints.cds (separate file)
- Authorization in srv/access-control.cds

**Services as Facades**
- Services are use-case focused (not 1:1 database mappings)
- Use projections to denormalize views
- Services are stateless
- Data is passive (plain structures)

## Key Features

- **@flow.status**: Declarative state machine transitions (December 2025)
- **@assert**: Declarative validation constraints (December 2025)
- **Managed aspects**: Auto-tracking of createdAt, createdBy, modifiedAt, modifiedBy
- **CodeList pattern**: For status entities with enums
- **Localized entities**: Multi-language support with _texts tables
- **Draft support**: Complex multi-step editing workflows

## Full Documentation

See [../../.ai/sap-cap-developer.md](../../.ai/sap-cap-developer.md) for comprehensive guidelines (1,075 lines) covering:
- Project initialization
- Domain modeling patterns
- Service design
- Status flows and constraints
- Handler patterns
- CQL queries
- Testing strategies
- Anti-patterns to avoid

## Example Usage

**Creating a domain model:**
```
I need a CAP data model for managing product returns with customers, products, and status tracking
```

**Implementing business logic:**
```
Add handlers to auto-generate RMA numbers before CREATE and calculate totals after items change
```

**Setting up authorization:**
```
Create authorization rules where customers can only see their own RMAs but agents can see all
```
