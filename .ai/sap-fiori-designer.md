---
name: sap-fiori-designer
description: 'This document provides guidance on selecting the appropriate SAP Fiori floorplan for your application, based on user needs and use cases. It helps determine navigation patterns, layout choices, and floorplan combinations.'
---

# SAP Fiori Designer

Choosing the right floorplan is an important decision as it directly impacts the user experience and functionality of your application. Each floorplan has its own strengths and weaknesses, so it's crucial to select the one that best fits your specific requirements and use case.

Your task is to help the user understand and implement the appropriate floorplan for their SAP Fiori application.

---

## Quick Decision Matrix

Use this matrix to quickly identify the right floorplan:

| User Need | Recommended Floorplan |
|-----------|----------------------|
| View/edit single object with details | **Object Page** |
| Browse large dataset, filter, act on items | **List Report** |
| Analyze data, drill down, KPIs | **Analytical List Page** |
| Process work items one by one | **Worklist** |
| Role-based dashboard with cards | **Overview Page** |
| Multi-step guided process | **Wizard** |
| Master-detail side by side | **Flexible Column Layout** |
| Find specific item by known value | **Initial Page** |
| Simple content, single section | **Dynamic Page** |
| None of the above fits | **Custom Page** |

---

## Decision Flow

Follow this flow to select the right floorplan:

```
START
  │
  ▼
┌─────────────────────────────────────┐
│ What is the primary user task?      │
└─────────────────────────────────────┘
  │
  ├─► View/Edit ONE object ──────────────────► OBJECT PAGE
  │
  ├─► Browse/Search MANY items
  │     │
  │     ├─► Need analytics/KPIs? ────────────► ANALYTICAL LIST PAGE
  │     │
  │     ├─► Work items to process? ──────────► WORKLIST
  │     │
  │     └─► General browsing ────────────────► LIST REPORT
  │
  ├─► Dashboard/Overview ────────────────────► OVERVIEW PAGE
  │
  ├─► Create new object
  │     │
  │     ├─► Complex/unfamiliar task? ────────► WIZARD
  │     │
  │     └─► Simple/familiar task ────────────► OBJECT PAGE (Create mode)
  │
  └─► Find known item by code ───────────────► INITIAL PAGE
```

---

## Floorplans

### List Report

With a list report, users can view and work with a large set of items. This floorplan offers powerful features for finding and acting on relevant items. It is often used as an entry point for navigating to the item details, which are usually shown on an object page.

**Key Features:**
- Filter bar with smart filters
- Table or chart visualization
- Multiple table views (tabs)
- Inline actions
- Batch operations
- Export to Excel
- Variant management

**When to Use:**
- Users need to find and act on relevant items within a large set of items by searching, filtering, sorting, and grouping.
- You want to let users display the whole dataset using different visualizations (for example, as a table or as a chart), but no interactions are required between these visualizations.
- Users need to work with multiple views of the same content, for example on items that are "Open", "In Process", or "Completed".
- Drilldown is rarely or never used, or is only available via navigation to another page.
- Users work on different kinds of items.

**Do Not Use If:**
- Users need to see or edit one item with all its details → Use **Object Page**
- Users need to find one specific item by known identifier → Use **Initial Page**
- Users need to work through a small set of items one by one → Use **Worklist**
- Users need analytics, KPIs, or drilldown → Use **Analytical List Page**
- Charts are used for more than visualization → Use **Analytical List Page**

**Typical Combination:**
```
List Report → Object Page → Sub-Object Page
```

---

### Object Page

The object page floorplan is used to display and categorize all relevant information about an object. Categorized content can be accessed quickly using anchor or tab navigation, and users can switch from display to edit mode to change the content.

**Key Features:**
- Header with key information and KPIs
- Anchor navigation (sections)
- Tab navigation (optional)
- Display/Edit/Create modes
- Actions in header and sections
- Related items (compositions)
- Draft support

**When to Use:**
- Users need to display, create, or edit an object.
- Users need to get an overview of an object and interact with different parts of the object.
- You need to structure your content into different sections.
- You have a page with one section and editable header content.

**Do Not Use If:**
- Users need to edit several items at the same time → Use **List Report** with inline edit
- Users need to find items without knowing exact details → Use **List Report**
- Users need guided multi-step creation → Use **Wizard**
- Creation process has different paths based on choices → Use **Wizard**
- Users need to find one specific item by code → Use **Initial Page**
- Users need analytics and drilldown → Use **Analytical List Page**
- Content fits in one section without editable header → Use **Dynamic Page**

**Typical Combinations:**
```
List Report → Object Page
Object Page → Sub-Object Page (via composition)
Overview Page → Object Page
```

---

### Analytical List Page

The analytical list page (ALP) offers a unique way to analyze data step by step from different perspectives, to investigate a root cause through drilldown, and to act on transactional content.

**Key Features:**
- Visual filters (chart-based filtering)
- KPI tags in header
- Hybrid view (chart + table)
- Drilldown capabilities
- Slice and dice
- Variant management

**When to Use:**
- Users need to extract key information to understand the current situation or identify a root cause.
- Users need to analyze data step by step from different perspectives.
- Users need to investigate a root cause through drilldown.
- Users need to see the impact of their filter settings in a chart (visual filter).
- Users need to switch between integrated chart and table views (hybrid view).
- Users need to see the impact of their action on a KPI.

**Do Not Use If:**
- Drilldown is rarely used or not needed → Use **List Report**
- Users don't need to work with both chart and table on same page → Use **List Report**
- Users need multiple views with tabs → Use **List Report**
- Users need to see or edit a single item → Use **Object Page**
- Users need to find a specific item by known code → Use **Initial Page**
- Users need to process work items one by one → Use **Worklist**
- Trivial use case with simple charts → Use **List Report** with chart switch

**Typical Combination:**
```
Analytical List Page → Object Page (for transactional follow-up)
```

---

### Worklist

A worklist displays a collection of items a user needs to process. Working through the list usually involves reviewing details of the items and taking action. The user has to either complete a work item or delegate it.

**Key Features:**
- Simple table-based layout
- Optional tabs for different states
- Optional KPI tags
- Quick actions
- Direct entry point for work items

**Variants:**
1. **Simple Worklist** — Plain page with a table
2. **Worklist with Tabs** — Multiple views (Open, In Process, Completed)
3. **Worklist with KPIs** — KPI tags showing counts or metrics

**When to Use:**
- Users have numerous work items and need to decide which ones to process first.
- You want to give users a direct entry point for taking action on work items.
- Users need to work with multiple views of the same content using tabs.

**Do Not Use If:**
- Items shown are not work items → Use **List Report**
- You want to show large item lists or combine data visualizations → Use **List Report**
- Users need to find and act on items by searching, filtering, sorting → Use **List Report**

**Typical Combination:**
```
Worklist → Object Page (for detailed processing)
```

---

### Overview Page

The overview page (OVP) is a data-driven SAP Fiori app type that provides all the information a user needs in a single page, based on the user's specific domain or role.

**Key Features:**
- Card-based layout
- Multiple card types (List, Table, Chart, Stack, Link)
- Global filter bar
- Micro actions on cards
- Content from multiple sources
- Role-specific views

**Card Types:**
- **List Card** — Simple list of items
- **Table Card** — Tabular data display
- **Analytical Card** — Charts and KPIs
- **Stack Card** — Grouped quick view cards
- **Link List Card** — Navigation links

**When to Use:**
- You want to provide an entry-level view of content related to a specific domain or role.
- Users need to filter and react to information from at least two different applications.
- You want to offer different information formats (charts, lists, tables) on a single page.
- You plan to have at least three cards of different types.

**Do Not Use If:**
- A high-level birds-eye view is sufficient → Use **Launchpad Home Page**
- You just want the user to launch an application → Use **Launchpad Home Page**
- You want to show information about one object only → Use **Object Page**
- You represent one application with less than three cards → Use **Object Page**

**Typical Combinations:**
```
Overview Page → List Report (via card navigation)
Overview Page → Object Page (via card navigation)
Overview Page → Analytical List Page (via card navigation)
```

---

### Wizard

The wizard floorplan allows users to complete a long or unfamiliar task by dividing it into sections and guiding the user through it.

**Key Features:**
- Step-by-step navigation
- Progress indicator
- Validation per step
- Summary page before submission
- Can be used in full screen or dialog

**Structure:**
1. **Walkthrough Screen** — Form sections revealed in sequence
2. **Summary Page** — Read-only review before final submission

**When to Use:**
- User has to accomplish a long task (such as filling out a long questionnaire).
- Task is unfamiliar to the user.
- Flow consists of 3-8 steps.
- You need to guide users through a specific sequence.

**Do Not Use If:**
- Task has only 2 steps → Use simpler approach
- Task is part of user's daily routine → Use **Object Page** create mode
- Process needs more than 8 steps → Restructure the task
- Classic edit flow is more suitable

**Typical Usage:**
```
List Report → Wizard (Create action)
Object Page → Wizard (Complex sub-process)
```

---

### Initial Page

The initial page floorplan helps users find one specific item when they already know an identifying data point (such as a code, number, or scanned value).

**Key Features:**
- Simple input field for identifier
- Quick search capability
- Direct navigation to object
- Optional recent items list
- Barcode scanner support

**When to Use:**
- Users need to find one specific item.
- The item or an identifying data point is known (code, number, barcode).
- Users want to bypass browsing and go directly to an object.

**Do Not Use If:**
- Users need to browse or filter items → Use **List Report**
- Users don't know the identifier → Use **List Report**
- Users need to see item details → Use **Object Page**

**Typical Combination:**
```
Initial Page → Object Page (direct navigation)
```

---

### Dynamic Page

The dynamic page provides a basic page layout with a collapsible header and a content area. It's the foundation for other floorplans but can also be used standalone.

**Key Features:**
- Collapsible header
- Single content area
- Optional filter bar
- Simple structure

**When to Use:**
- Your content can be shown in just one section.
- You don't have editable header content.
- You need a simple, focused page.

**Do Not Use If:**
- You need multiple sections → Use **Object Page**
- You need editable header → Use **Object Page**
- You need filter and table → Use **List Report**

---

### Custom Page

You can build your SAP Fiori elements app from a blank custom page while still getting full support through building blocks.

**Key Features:**
- Complete layout freedom
- Building block support
- Full control over UI
- Custom components

**When to Use:**
- Custom page layout not covered by standard floorplans.
- Need to integrate custom components.
- Specific requirements not met by standard floorplans.

**Do Not Use If:**
- Standard floorplans can meet your requirements.
- You want maximum framework support and consistency.

---

## Flexible Column Layout (FCL)

The Flexible Column Layout (FCL) is a **layout pattern**, not a floorplan. It allows displaying up to three pages side by side, enabling master-detail and master-detail-detail patterns.

### Column Configurations

| Layout | Description | Use Case |
|--------|-------------|----------|
| **One Column** | Full screen, single page | Simple navigation |
| **Two Columns** | List + Detail (67/33 or 33/67) | Master-detail |
| **Three Columns** | List + Detail + Sub-detail | Master-detail-detail |
| **Mid Expanded** | Middle column expanded | Focus on detail |
| **End Expanded** | Right column expanded | Focus on sub-detail |

### Visual Representation

```
┌─────────────────────────────────────────────────────────┐
│ ONE COLUMN (Full Screen)                                │
│ ┌─────────────────────────────────────────────────────┐ │
│ │                                                     │ │
│ │              List Report                            │ │
│ │                                                     │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ TWO COLUMNS (Master-Detail)                             │
│ ┌──────────────────────┐ ┌────────────────────────────┐ │
│ │                      │ │                            │ │
│ │   List Report        │ │     Object Page            │ │
│ │   (Master)           │ │     (Detail)               │ │
│ │                      │ │                            │ │
│ └──────────────────────┘ └────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ THREE COLUMNS (Master-Detail-Detail)                    │
│ ┌────────────┐ ┌────────────────┐ ┌───────────────────┐ │
│ │            │ │                │ │                   │ │
│ │ List       │ │ Object         │ │ Sub-Object        │ │
│ │ Report     │ │ Page           │ │ Page              │ │
│ │            │ │                │ │                   │ │
│ └────────────┘ └────────────────┘ └───────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### When to Use FCL

**Use FCL When:**
- Users frequently switch between list and detail views.
- Context of the list is important while viewing details.
- Users need to compare items quickly.
- Master-detail relationship is central to the workflow.
- Screen real estate allows side-by-side viewing.

**Use Full Screen Navigation When:**
- Details require full attention.
- Complex object pages with many sections.
- Mobile-first design requirement.
- Users don't need to see list while editing.
- Simple create/edit/display workflow.

### FCL Configuration in manifest.json

```json
{
  "sap.ui5": {
    "routing": {
      "config": {
        "flexibleColumnLayout": {
          "defaultTwoColumnLayoutType": "TwoColumnsMidExpanded",
          "defaultThreeColumnLayoutType": "ThreeColumnsMidExpanded"
        }
      },
      "routes": [
        {
          "pattern": ":?query:",
          "name": "TravelList",
          "target": "TravelList"
        },
        {
          "pattern": "Travel({key}):?query:",
          "name": "TravelDetail",
          "target": ["TravelList", "TravelDetail"]
        },
        {
          "pattern": "Travel({key})/Booking({key2}):?query:",
          "name": "BookingDetail",
          "target": ["TravelList", "TravelDetail", "BookingDetail"]
        }
      ],
      "targets": {
        "TravelList": {
          "type": "Component",
          "id": "TravelList",
          "name": "sap.fe.templates.ListReport",
          "options": {
            "settings": {
              "contextPath": "/Travel",
              "controlConfiguration": {
                "@com.sap.vocabularies.UI.v1.LineItem": {
                  "tableSettings": {
                    "type": "ResponsiveTable"
                  }
                }
              }
            }
          }
        },
        "TravelDetail": {
          "type": "Component",
          "id": "TravelDetail",
          "name": "sap.fe.templates.ObjectPage",
          "options": {
            "settings": {
              "contextPath": "/Travel"
            }
          }
        },
        "BookingDetail": {
          "type": "Component",
          "id": "BookingDetail",
          "name": "sap.fe.templates.ObjectPage",
          "options": {
            "settings": {
              "contextPath": "/Travel/to_Booking"
            }
          }
        }
      }
    }
  }
}
```

---

## Common Floorplan Combinations

### Pattern 1: Standard Business Object

```
List Report → Object Page
```

**Use Case:** Browse orders, view/edit order details
**Example:** Sales Orders, Purchase Orders, Products

### Pattern 2: Master-Detail-Detail

```
List Report → Object Page → Sub-Object Page
```

**Use Case:** Hierarchical data with compositions
**Example:** Travel → Bookings → Booking Supplements

### Pattern 3: Analytics to Transaction

```
Analytical List Page → Object Page
```

**Use Case:** Analyze KPIs, then act on specific items
**Example:** Sales Analysis → Sales Order

### Pattern 4: Role-Based Dashboard

```
Overview Page → List Report → Object Page
                    ↓
              Object Page
```

**Use Case:** Role dashboard with quick access to multiple apps
**Example:** Manager Dashboard → Team Tasks → Task Details

### Pattern 5: Guided Creation

```
List Report → Wizard → Object Page (View created item)
```

**Use Case:** Complex object creation requiring guidance
**Example:** Contract Creation, Configuration Wizard

### Pattern 6: Work Processing

```
Worklist → Object Page → Back to Worklist
```

**Use Case:** Process work items sequentially
**Example:** Approval Workflow, Task Processing

### Pattern 7: Quick Find

```
Initial Page → Object Page
```

**Use Case:** Find specific item by known ID
**Example:** Warehouse scanning, Direct item lookup

---

## Responsive Behavior

### Desktop (>1440px)

| Floorplan | Behavior |
|-----------|----------|
| List Report | Full filter bar, responsive table |
| Object Page | All sections visible, anchor navigation |
| ALP | Full visual filters, hybrid view |
| FCL | Up to 3 columns |

### Tablet (600-1440px)

| Floorplan | Behavior |
|-----------|----------|
| List Report | Condensed filter bar, responsive table |
| Object Page | Anchor navigation, sections stack |
| ALP | Visual filters collapse, hybrid view |
| FCL | Up to 2 columns |

### Mobile (<600px)

| Floorplan | Behavior |
|-----------|----------|
| List Report | Filter dialog, list-style table |
| Object Page | Tab navigation, sections as pages |
| ALP | Limited functionality, consider List Report |
| FCL | Single column only (full screen) |

### Mobile Considerations

- **List Report** works well on mobile
- **Object Page** adapts with tab navigation
- **ALP** has limited mobile support — consider List Report alternative
- **Overview Page** cards stack vertically
- **FCL** degrades to full screen navigation
- **Worklist** works well for mobile task processing

---

## Performance Considerations

### Large Data Sets (>10,000 records)

| Floorplan | Recommendation |
|-----------|----------------|
| List Report | ✅ Excellent — pagination, lazy loading |
| ALP | ⚠️ Consider aggregation, limit visual filters |
| Worklist | ⚠️ Consider filtering to reduce set |
| Object Page | ✅ Good — single object focus |
| Overview Page | ✅ Good — cards limit data per view |

### Complex Objects (Many Fields/Associations)

| Floorplan | Recommendation |
|-----------|----------------|
| Object Page | ✅ Use sections, lazy load tabs |
| List Report | ⚠️ Limit visible columns, use expandable |
| FCL | ⚠️ May cause performance issues with complex pages |

### Real-time Data

| Floorplan | Recommendation |
|-----------|----------------|
| ALP | ✅ Good for KPI monitoring |
| Overview Page | ✅ Cards can auto-refresh |
| Worklist | ✅ Good for task queues |
| List Report | ⚠️ Manual refresh typically needed |

---

## Launchpad Integration

### Tile Types

| Tile Type | Use Case | Target |
|-----------|----------|--------|
| Static | Fixed info, app launch | Any floorplan |
| Dynamic | Live count/KPI | List Report, Worklist |
| KPI | Real-time metrics | ALP, Overview Page |
| News | Notifications | Any floorplan |

### Intent Navigation

```
SemanticObject-Action
```

**Examples:**
- `SalesOrder-display` → Object Page
- `SalesOrder-manage` → List Report
- `SalesOrder-analyze` → Analytical List Page
- `SalesOrder-create` → Wizard or Object Page

### Cross-App Navigation Configuration

```json
{
  "sap.app": {
    "crossNavigation": {
      "inbounds": {
        "SalesOrder-manage": {
          "semanticObject": "SalesOrder",
          "action": "manage",
          "title": "Manage Sales Orders",
          "signature": {
            "parameters": {
              "SalesOrderID": { "required": false }
            }
          }
        }
      }
    }
  }
}
```

---

## Quick Reference

### Floorplan Selection Summary

| Floorplan | Primary Purpose | Data Volume | Edit Capability |
|-----------|----------------|-------------|-----------------|
| List Report | Browse, filter, act | Large | Limited (inline) |
| Object Page | View/edit single item | Single | Full |
| ALP | Analyze, drill down | Large | Limited |
| Worklist | Process tasks | Medium | Via navigation |
| Overview Page | Role dashboard | Multiple sources | Via navigation |
| Wizard | Guided creation | New object | Full (sequential) |
| Initial Page | Quick find | Single | Via navigation |
| Dynamic Page | Simple content | Varies | Varies |
| Custom Page | Special needs | Varies | Varies |

### FCL vs Full Screen

| Criterion | FCL | Full Screen |
|-----------|-----|-------------|
| Context preservation | ✅ | ❌ |
| Screen real estate | ❌ | ✅ |
| Mobile support | Limited | ✅ |
| Quick comparison | ✅ | ❌ |
| Complex editing | ❌ | ✅ |
| Performance | ⚠️ | ✅ |

### Common Mistakes to Avoid

| Mistake | Better Approach |
|---------|-----------------|
| Using ALP for simple lists | Use List Report |
| Object Page with one section | Use Dynamic Page |
| Wizard for familiar tasks | Use Object Page create mode |
| Overview Page with <3 cards | Use Object Page or List Report |
| FCL on complex object pages | Use full screen |
| List Report for work items | Use Worklist |

---

## Validation Checklist

Before finalizing floorplan selection:

- [ ] Identified primary user task
- [ ] Considered data volume and performance
- [ ] Evaluated mobile requirements
- [ ] Planned navigation flow between floorplans
- [ ] Decided FCL vs full screen
- [ ] Considered analytics requirements
- [ ] Reviewed responsive behavior needs
- [ ] Planned Launchpad tile type
- [ ] Defined semantic object and actions
- [ ] Validated combination with related apps

---

## Key Reminders

1. **Start with user task** — What does the user need to accomplish?
2. **Consider data volume** — Large datasets need List Report or ALP
3. **Think responsive** — Mobile behavior varies significantly
4. **Plan navigation** — How do floorplans connect?
5. **FCL is optional** — Full screen is often simpler and better
6. **Don't over-engineer** — Use simplest floorplan that meets needs
7. **Analytics need ALP** — List Report charts are for visualization only
8. **Worklist for tasks** — Not just any list of items
9. **Overview Page needs cards** — At least 3, different types
10. **Wizard has limits** — 3-8 steps, not for daily tasks
