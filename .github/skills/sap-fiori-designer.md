---
name: sap-fiori-designer
description: Expert at choosing the right SAP Fiori floorplan for specific use cases and user roles
---

# SAP Fiori Designer Skill

This skill helps select the optimal SAP Fiori Elements floorplan based on your business requirements and user needs.

## When to Use

- Choosing between List Report, Object Page, Worklist, Analytical List Page, etc.
- Deciding on appropriate floorplans for different user roles
- Understanding navigation patterns (e.g., List Report → Object Page)
- Planning multi-app Fiori architectures
- Evaluating when to use custom vs. standard floorplans

## How to Invoke

From your IDE (VSCode/Cursor with Claude Code extension):

```
Which Fiori floorplan should I use for a task approval workflow?
```

```
Help me choose floorplans for an RMA system with customers, agents, inspectors, and managers
```

## Available Floorplans

1. **List Report Object Page (LROP)** - Browse datasets, drill into details
2. **Worklist** - Process tasks one by one with actions
3. **Analytical List Page (ALP)** - Analytics, KPIs, charts, visual filters
4. **Overview Page (OVP)** - Dashboard with role-based cards
5. **Wizard** - Multi-step guided processes
6. **Flexible Column Layout (FCL)** - Master-detail side by side
7. **Object Page** - Display/edit single object with sections
8. **Initial Page** - Find items by known identifier
9. **Dynamic Page** - Simple content display
10. **Custom Page** - Non-standard layouts

## Decision Factors

The skill considers:
- **User role** (browser, processor, analyst, decision maker)
- **Task type** (browse, process, analyze, monitor)
- **Data volume** (few records vs. large datasets)
- **Navigation needs** (drill-down, side-by-side, sequential)
- **Analytics requirements** (KPIs, charts, visual filters)

## Full Documentation

See [../../.ai/sap-fiori-designer.md](../../.ai/sap-fiori-designer.md) for:
- Detailed floorplan descriptions (751 lines)
- Decision matrices
- When-to-use vs. when-NOT-to-use guidelines
- Navigation patterns
- Multi-app architecture examples

## Example Usage

**Single floorplan selection:**
```
I need a UI for warehouse staff to process incoming returns - which floorplan?
```

**Multi-role application:**
```
Design floorplans for: customers submitting returns, agents approving them, and managers viewing analytics
```

**Navigation planning:**
```
How should users navigate from a list of orders to order details to individual line items?
```
