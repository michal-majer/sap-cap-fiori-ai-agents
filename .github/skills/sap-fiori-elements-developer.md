---
name: sap-fiori-elements-developer
description: Expert in SAP Fiori Elements UI annotations for rich, metadata-driven user interfaces
---

# SAP Fiori Elements Developer Skill

This skill provides comprehensive guidance for implementing UI annotations that create professional, feature-rich Fiori applications through metadata.

## When to Use

- Adding UI annotations to CAP services (@UI.LineItem, @UI.FieldGroup, @UI.HeaderInfo)
- Implementing value helps and dropdowns (@Common.ValueList, @Common.ValueListWithFixedValues)
- Creating contact cards for customer/supplier data (@Communication.Contact)
- Adding criticality colors and semantic styling (@UI.Criticality)
- Configuring field control, validation, and side effects
- Setting up charts and visual filters (for Analytical List Page)
- Implementing actions in line items and object pages

## How to Invoke

From your IDE (VSCode/Cursor with Claude Code extension):

```
Add value helps to all foreign key fields in my service
```

```
Create UI annotations for a List Report showing products with criticality colors
```

```
Implement contact cards for customer information in the object page
```

## Core Principles

**Human-Friendly Labels Everywhere**
- Never show technical IDs to users
- Use @Common.Label for all fields
- Use @Common.Text with @UI.TextArrangement for descriptions

**Value Helps for All References**
- Small fixed lists (< 15 items) → @Common.ValueListWithFixedValues (dropdown)
- Large dynamic lists → @Common.ValueList (search dialog)
- Auto-fill dependent fields with In/Out mappings

**Professional Contact Display**
- Use @Communication.Contact for customer/supplier fields
- Creates vCard-style contact cards
- Supports photo, email, phone, address

**Smart UI Behavior**
- @UI.Criticality for color coding (0=neutral, 1=negative, 2=critical, 3=positive)
- Side effects for auto-refresh after actions
- Field control for conditional visibility/editability

## Key Annotations

- **@UI.LineItem** - Table columns and inline actions
- **@UI.HeaderInfo** - Object page header (title, type, image)
- **@UI.Facets** - Object page sections and subsections
- **@UI.FieldGroup** - Form field groupings
- **@UI.SelectionFields** - Filter bar fields
- **@Common.ValueList** - Search dialog value help
- **@Common.ValueListWithFixedValues** - Dropdown value help
- **@Communication.Contact** - Contact card display
- **@UI.Chart** - Charts for analytics
- **@UI.KPI** - Key performance indicators

## Full Documentation

See [../../.ai/sap-fiori-elements-developer.md](../../.ai/sap-fiori-elements-developer.md) for:
- Complete annotation reference (2,390 lines)
- Before/after examples
- Value help strategies
- Contact card patterns
- Chart configurations
- Anti-patterns to avoid

## Example Usage

**Basic annotations:**
```
Add table columns, filters, and form fields for my Products entity
```

**Value helps:**
```
Implement a searchable value help for the customer field with auto-fill for email and phone
```

**Advanced UI:**
```
Add a worklist with tabs (Pending, Approved, Rejected), actions, and KPI headers showing counts
```

**Analytics:**
```
Create an Analytical List Page with charts showing returns by reason and visual filters
```
