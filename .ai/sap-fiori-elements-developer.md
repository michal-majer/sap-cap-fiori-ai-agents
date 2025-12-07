---
name: fiori-elements-developer
description: "Use this skill when developing SAP Fiori applications with SAP Fiori elements. It provides guidance on required annotations, explaining which to use and when, and ensures all necessary annotations are applied for specific goals."
---

# SAP Fiori Elements Developer

This document provides guidance on developing SAP Fiori applications with SAP Fiori elements. It focuses on required annotations, explaining which to use and when, and ensures all necessary annotations are applied for specific goals.

## GOAL

Build the **BEST-ENTERPRISE-APPLICATION-FIORI-EVER** using CDS annotations to their full potential.  
The app must look **professional, consistent, and clearly crafted by an expert**.

Top priority:  
Provide **proper, human-friendly labels** everywhere (tables, fields, search helps, value helps).  
For example, instead of `customer_ID` it should be **Customer ID**.

**Always provide Value Helps wherever possible.** Users should never guess what to enter when a controlled list exists.

**Use Contact Fields for customer/organization data.** Whenever entities contain contact information (name, email, phone), implement `@Communication.Contact` annotation to display professional contact cards that users can click to see all details.

For Search/Value Help results:

- If the data has **key/name pairs**, always display the **name** to the user.
- If additional context is helpful, show **name + descriptive fields**.
- **Never display technical keys** (especially UUIDs or opaque IDs).

**Choose the right value help type:**
- **Fixed/Small lists (typically < 15 entries)** → Use **`ValueListWithFixedValues: true`** to display as a **dropdown/select list** (no dialog). This provides faster selection for small code lists like status codes, return reasons, priority levels.
- **Large or dynamic lists** → Use regular **`ValueList`** to display as a **dialog with search/typeahead** for entities like customers, products, or other master data.

To achieve this:

- Always check **underlying CDS/OData services** first for existing value help entities.  
- Use **ValueList**, **ValueListWithFixedValues**, **ValueListForValidation**, **TextArrangement**, and **SearchRestrictions** to deliver a polished UX.  
- Apply **In/Out/DisplayOnly mappings** to auto-fill dependent fields.  
- Use **context-dependent value helps** or **multiple value help variants** when required.  
- Apply **side effects** to refresh dependent UI areas immediately after user actions.  
- Ensure every field "feels Fiori": intuitive, supported, and business-context aware.

---

## Additional Key Principles

### Strong Validation

- Validate on focus-out with **ValueListForValidation**.  
- Enforce backend validation using CDS checks.  
- Show clear, consistent error messages.

### Correct Control for Each Field Type

Match UI control to semantics:

- Date → **DatePicker**  
- DateTime → **DateTimePicker**  
- Boolean → **Switch**  
- Numeric → **Number / StepInput**  
- Small fixed lists → **Dropdown**  
- Long text → **TextArea**

### Consistent Semantic Enrichment

Use semantic annotations:

- Navigation via **@UI.semanticObject**  
- Key + Description via **@Common.TextArrangement**  
- Units & currencies via **@Measures.Unit** / **@Measures.ISOCurrency**  
- Communication fields for email/phone/URL

### Smart UI Refresh with Side Effects

- Auto-update dependent fields
- Refresh lists/sections after changes
- Recalculate values dynamically

### Contact Cards for Professional UX

Whenever you have customer/organization/contact entities with email/phone data:

- **Always implement `@Communication.Contact`** - Creates professional, clickable contact cards
- **Structure**:
  - `fn` (full name) - main display value
  - `org` (organization) - company/department info
  - `tel` (phone) - clickable phone numbers
  - `email` (email) - clickable email addresses
  - `photo` (icon) - visual identifier
- **Pair with `@Communication.IsEmailAddress` and `@Communication.IsPhoneNumber`** - Makes fields clickable
- **Use `Common.IsNaturalPerson: false`** - For organizations, not individuals
- **Display in fields as `DataFieldForAnnotation`** - Creates clickable contact popover
- **Example**: Show only company name in list, full contact details open on click

---

## Project Structure for Annotations

Organize annotation files for maintainability:

```
app/
├── fiori-app/
│   ├── annotations.cds           # Main annotations file
│   ├── labels.cds                # Labels and i18n references
│   ├── value-helps.cds           # All value help definitions
│   ├── field-control.cds         # Field visibility and editability
│   └── webapp/
│       ├── manifest.json
│       └── ext/                   # Extensions folder
│           ├── fragment/          # Custom fragments
│           └── controller/        # Controller extensions
srv/
├── annotations/                   # Server-side annotations (optional)
│   ├── travel-annotations.cds
│   └── booking-annotations.cds
```

### Annotation File Organization Pattern

```cds
// app/fiori-app/annotations.cds — Main entry point
using TravelService from '../../srv/travel-service';

// Import separated concerns
using from './labels';
using from './value-helps';
using from './field-control';

// Core UI annotations here
annotate TravelService.Travel with @UI: { ... };
```

---

## Annotations Overview

Annotations are used to configure and customize SAP Fiori elements applications. They provide a way to define the behavior and appearance of the application without changing the underlying code.

### Common Annotations

- **`@UI.Facets`**: Used to define the structure and layout of the application.
- **`@UI.LineItem`**: Defines the columns to be displayed in a table or list.
- **`@UI.Identification`**: Defines the fields to be displayed in the header of an object page.
- **`@UI.SelectionFields`**: Defines the fields available for filtering and searching.
- **`@UI.FieldGroup`**: Groups related fields together in the UI.
- **`@UI.Hidden`**: Hides a field from the UI.
- **`@UI.HeaderFacets`**: Defines KPI tiles/cards in the object page header.
- **`@UI.HeaderInfo`**: Defines title, description, and image for the object page header.

---

## Table Annotations (LineItem)

### Basic Table Configuration

```cds
annotate TravelService.Travel with @UI: {
  LineItem: [
    { $Type: 'UI.DataField', Value: TravelID, ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: Description, ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: BeginDate },
    { $Type: 'UI.DataField', Value: EndDate },
    { 
      $Type: 'UI.DataField', 
      Value: TotalPrice,
      ![@UI.Importance]: #High
    },
    { 
      $Type: 'UI.DataField', 
      Value: TravelStatus_code,
      Criticality: TravelStatus.criticality,
      ![@UI.Importance]: #High
    }
  ]
};
```

### Table with Actions

```cds
annotate TravelService.Travel with @UI: {
  LineItem: [
    { $Type: 'UI.DataField', Value: TravelID },
    { $Type: 'UI.DataField', Value: Description },
    // Inline action button
    {
      $Type : 'UI.DataFieldForAction',
      Action: 'TravelService.acceptTravel',
      Label : 'Accept',
      Inline: true,
      ![@UI.Importance]: #High
    },
    // Action in toolbar (not inline)
    {
      $Type : 'UI.DataFieldForAction',
      Action: 'TravelService.rejectTravel',
      Label : 'Reject'
    }
  ]
};
```

### Table with Navigation

```cds
annotate TravelService.Travel with @UI: {
  LineItem: [
    { $Type: 'UI.DataField', Value: TravelID },
    // Navigation to related object
    {
      $Type : 'UI.DataFieldWithIntentBasedNavigation',
      Value : to_Agency.Name,
      SemanticObject: 'TravelAgency',
      Action: 'display'
    },
    // Navigation with URL
    {
      $Type: 'UI.DataFieldWithUrl',
      Value: to_Agency.Name,
      Url  : to_Agency.WebAddress
    }
  ]
};
```

### Table Column Importance

Control which columns show on different screen sizes:

```cds
// #High — Always visible (mobile, tablet, desktop)
// #Medium — Visible on tablet and desktop
// #Low — Visible only on desktop (hidden on mobile/tablet)

annotate TravelService.Travel with @UI.LineItem: [
  { Value: TravelID, ![@UI.Importance]: #High },      // Always visible
  { Value: Description, ![@UI.Importance]: #High },   // Always visible
  { Value: BeginDate, ![@UI.Importance]: #Medium },   // Tablet+
  { Value: EndDate, ![@UI.Importance]: #Medium },     // Tablet+
  { Value: BookingFee, ![@UI.Importance]: #Low },     // Desktop only
  { Value: TotalPrice, ![@UI.Importance]: #High }     // Always visible
];
```

### Multiple LineItem Variants

```cds
// Default table
annotate TravelService.Travel with @UI.LineItem: [ ... ];

// Simplified variant for dashboards
annotate TravelService.Travel with @UI.LineItem #Simple: [
  { Value: TravelID },
  { Value: Description },
  { Value: TravelStatus_code, Criticality: TravelStatus.criticality }
];

// Detailed variant for admin views
annotate TravelService.Travel with @UI.LineItem #Detailed: [
  { Value: TravelID },
  { Value: Description },
  { Value: BeginDate },
  { Value: EndDate },
  { Value: BookingFee },
  { Value: TotalPrice },
  { Value: createdBy },
  { Value: createdAt },
  { Value: modifiedBy },
  { Value: modifiedAt }
];
```

---

## Object Page Header

### HeaderInfo — Title and Subtitle

```cds
annotate TravelService.Travel with @UI: {
  HeaderInfo: {
    TypeName      : 'Travel',
    TypeNamePlural: 'Travels',
    Title         : { $Type: 'UI.DataField', Value: Description },
    Description   : { $Type: 'UI.DataField', Value: TravelID },
    ImageUrl      : 'sap-icon://flight',
    TypeImageUrl  : 'sap-icon://flight'
  }
};
```

### HeaderFacets — KPI Visualizations

**Purpose:** Display key performance indicators as visual cards with progress bars, criticality colors, and formatted values.

**⚡ Quick Summary - Getting Colors to Work:**

- Use `Criticality` field pointing to virtual field
- Calculate criticality values (0-3) in JavaScript `after('READ')` handler
- Values: 0=Grey, 1=Red, 2=Orange, 3=Green

```cds
annotate TravelService.Travel with @UI: {
  HeaderFacets: [
    {
      $Type : 'UI.ReferenceFacet',
      Target: '@UI.DataPoint#TotalPrice',
      ID    : 'TotalPriceFacet'
    },
    {
      $Type : 'UI.ReferenceFacet',
      Target: '@UI.DataPoint#Progress',
      ID    : 'ProgressFacet'
    },
    {
      $Type : 'UI.ReferenceFacet',
      Target: '@UI.FieldGroup#AdminData',
      Label : 'Administrative Data'
    }
  ],
  DataPoint #TotalPrice: {
    Value      : TotalPrice,
    Title      : 'Total Price',
    Criticality: priceCriticality  // Virtual field
  },
  DataPoint #Progress: {
    Value        : completionPercent,
    TargetValue  : 100,
    Title        : 'Completion',
    Visualization: #Progress,
    Criticality  : progressCriticality
  }
};
```

### Criticality Values

| Value | Color  | Use Case |
|-------|--------|----------|
| 0     | Grey   | Neutral/Information |
| 1     | Red    | Negative/Error |
| 2     | Orange | Critical/Warning |
| 3     | Green  | Positive/Success |
| 5     | Blue   | New Item (special) |

### Calculating Criticality in Handler

```javascript
this.after('READ', 'Travel', (data) => {
  const travels = Array.isArray(data) ? data : [data];
  travels.forEach(travel => {
    // Price criticality
    if (travel.TotalPrice > 10000) {
      travel.priceCriticality = 1;  // Red - expensive
    } else if (travel.TotalPrice > 5000) {
      travel.priceCriticality = 2;  // Orange - moderate
    } else {
      travel.priceCriticality = 3;  // Green - cheap
    }

    // Progress criticality
    if (travel.completionPercent >= 80) {
      travel.progressCriticality = 3;  // Green
    } else if (travel.completionPercent >= 50) {
      travel.progressCriticality = 2;  // Orange
    } else {
      travel.progressCriticality = 1;  // Red
    }
  });
});
```

---

## Object Page Facets (Sections and Tabs)

### Basic Facet Structure

```cds
annotate TravelService.Travel with @UI: {
  Facets: [
    // Section with field groups
    {
      $Type : 'UI.CollectionFacet',
      ID    : 'GeneralInfo',
      Label : 'General Information',
      Facets: [
        {
          $Type : 'UI.ReferenceFacet',
          Target: '@UI.FieldGroup#TravelData',
          Label : 'Travel Details'
        },
        {
          $Type : 'UI.ReferenceFacet',
          Target: '@UI.FieldGroup#Dates',
          Label : 'Dates'
        }
      ]
    },
    // Section with table (composition)
    {
      $Type : 'UI.ReferenceFacet',
      Target: 'to_Booking/@UI.LineItem',
      Label : 'Bookings'
    },
    // Section with contact card
    {
      $Type : 'UI.ReferenceFacet',
      Target: 'to_Agency/@Communication.Contact',
      Label : 'Agency Contact'
    }
  ],
  FieldGroup #TravelData: {
    Data: [
      { Value: TravelID },
      { Value: Description },
      { Value: to_Agency_AgencyID }
    ]
  },
  FieldGroup #Dates: {
    Data: [
      { Value: BeginDate },
      { Value: EndDate }
    ]
  }
};
```

### Nested Facets (Tabs within Sections)

```cds
annotate TravelService.Travel with @UI.Facets: [
  {
    $Type : 'UI.CollectionFacet',
    ID    : 'TravelDetails',
    Label : 'Travel Details',
    Facets: [
      // Tab 1
      {
        $Type : 'UI.CollectionFacet',
        ID    : 'BasicInfo',
        Label : 'Basic Info',
        Facets: [
          { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#Basic' }
        ]
      },
      // Tab 2
      {
        $Type : 'UI.CollectionFacet',
        ID    : 'Financial',
        Label : 'Financial',
        Facets: [
          { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#Costs' }
        ]
      }
    ]
  }
];
```

---

## Actions (Bound and Unbound)

### Declaring Actions in CDS

```cds
service TravelService {
  entity Travel as projection on db.Travel actions {
    // Bound actions (entity-level)
    action acceptTravel() returns Travel;
    action rejectTravel(reason: String) returns Travel;
    action copyTravel() returns Travel;
  };

  // Unbound actions (service-level)
  action createTravelFromTemplate(templateID: UUID) returns Travel;
  function getTravelStatistics() returns { total: Integer; approved: Integer };
}
```

### Action Annotations

```cds
// Button styling and placement
annotate TravelService.acceptTravel with @(
  Core.OperationAvailable: { $edmJson: { $Ne: [{ $Path: 'TravelStatus_code' }, 'A'] } },
  Common.SideEffects: { TargetEntities: ['_it'] }
);

annotate TravelService.rejectTravel with @(
  Core.OperationAvailable: { $edmJson: { $Ne: [{ $Path: 'TravelStatus_code' }, 'X'] } },
  Common.SideEffects: { TargetProperties: ['_it/TravelStatus_code'] }
);
```

### Actions in LineItem (Table)

```cds
annotate TravelService.Travel with @UI.LineItem: [
  { Value: TravelID },
  { Value: Description },
  // Inline action (appears in row)
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'TravelService.acceptTravel',
    Label : 'Accept',
    Inline: true,
    IconUrl: 'sap-icon://accept',
    ![@UI.Importance]: #High
  },
  // Toolbar action (appears in table toolbar)
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'TravelService.rejectTravel',
    Label : 'Reject',
    Inline: false
  }
];
```

### Actions in Object Page Header

```cds
annotate TravelService.Travel with @UI.Identification: [
  { Value: TravelID },
  // Header action buttons
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'TravelService.acceptTravel',
    Label : 'Accept Travel'
  },
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'TravelService.rejectTravel',
    Label : 'Reject Travel'
  },
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'TravelService.copyTravel',
    Label : 'Copy'
  }
];
```

### Action with Parameters (Dialog)

```cds
// In service definition
action rejectTravel(
  @UI.ParameterDefaultValue: 'Not approved'
  reason: String(256)
) returns Travel;

// Annotation for parameter labels
annotate TravelService.rejectTravel with {
  reason @Common.Label: 'Rejection Reason' @UI.MultiLineText;
};
```

### Conditional Action Availability

**Pattern 1: Simple Boolean Property**

```cds
// Using path to boolean property
annotate TravelService.acceptTravel with @Core.OperationAvailable: IsEditable;
```

**Pattern 2: Status-Based Conditions with Multiple Checks**

Use `$And` for multiple required conditions (e.g., specific status AND active entity):

```cds
annotate InvoiceService.postInvoice with @Core.OperationAvailable: {
  $edmJson: {
    $And: [
      { $Eq: [{ $Path: 'status_code' }, 'PARKED'] },     // Status must be PARKED
      { $Eq: [{ $Path: 'IsActiveEntity' }, true] }        // Must be active (not draft)
    ]
  }
};

annotate InvoiceService.revertPosting with @Core.OperationAvailable: {
  $edmJson: {
    $And: [
      { $Eq: [{ $Path: 'status_code' }, 'POSTED'] },      // Status must be POSTED
      { $Eq: [{ $Path: 'IsActiveEntity' }, true] }        // Must be active
    ]
  }
};
```

**Backend Implementation for Status-Changing Actions**

```javascript
// Service definition
service InvoiceService {
  entity Invoices as projection on db.Invoices actions {
    @(Common.SideEffects: { TargetEntities: ['_it'] })
    action postInvoice() returns Invoices;

    @(Common.SideEffects: { TargetEntities: ['_it'] })
    action revertPosting() returns Invoices;
  }
}

// Handler implementation
srv.on('postInvoice', async req => {
  const { params: invoices } = req;
  const { ID } = invoices.pop();
  await UPDATE.entity(Invoices, ID).set({ status_code: 'POSTED' });
  return await SELECT.one(Invoices).where({ ID });
});

srv.on('revertPosting', async req => {
  const { params: invoices } = req;
  const { ID } = invoices.pop();
  await UPDATE.entity(Invoices, ID).set({ status_code: 'PARKED' });
  return await SELECT.one(Invoices).where({ ID });
});
```

**Conditional Facet Visibility Using Status**

Hide/show header KPI cards based on status:

```cds
annotate InvoiceService.Invoices with @UI.HeaderFacets: [
  {
    $Type: 'UI.ReferenceFacet',
    ID: 'ParkedFacet',
    Target: '@UI.DataPoint#ParkedStatus',
    // Hide when status is POSTED or in draft mode
    ![@UI.Hidden]: {
      $edmJson: {
        $Or: [
          { $Eq: [{ $Path: 'status_code' }, 'POSTED'] },
          { $Eq: [{ $Path: 'IsActiveEntity' }, false] }
        ]
      }
    }
  },
  {
    $Type: 'UI.ReferenceFacet',
    ID: 'PostedFacet',
    Target: '@UI.DataPoint#PostedStatus',
    // Hide when status is PARKED or in draft mode
    ![@UI.Hidden]: {
      $edmJson: {
        $Or: [
          { $Eq: [{ $Path: 'status_code' }, 'PARKED'] },
          { $Eq: [{ $Path: 'IsActiveEntity' }, false] }
        ]
      }
    }
  }
];

annotate InvoiceService.Invoices with @UI: {
  DataPoint #ParkedStatus: {
    Value: status_code,
    Title: 'Status: Parked',
    Visualization: #Status
  },
  DataPoint #PostedStatus: {
    Value: status_code,
    Title: 'Status: Posted',
    Visualization: #Status
  }
};
```

**Key Points:**
- ✅ Use `$And` when ALL conditions must be true (e.g., status = X AND IsActiveEntity = true)
- ✅ Use `$Or` when ANY condition is true (e.g., hide if status = POSTED OR draft mode)
- ✅ Always check `IsActiveEntity: true` to prevent actions on draft records
- ✅ Use `@Common.SideEffects: { TargetEntities: ['_it'] }` to refresh the page after action
- ✅ Status-changing actions return the updated entity for immediate refresh
- ✅ Use conditional `@UI.Hidden` in facets to show relevant KPIs per status

---

## Charts

### Basic Chart Definition

```cds
annotate TravelService.Travel with @UI: {
  Chart: {
    $Type            : 'UI.ChartDefinitionType',
    Title            : 'Travel by Status',
    ChartType        : #Column,
    Dimensions       : [TravelStatus_code],
    DimensionAttributes: [{
      $Type    : 'UI.ChartDimensionAttributeType',
      Dimension: TravelStatus_code,
      Role     : #Category
    }],
    Measures         : [TotalPrice],
    MeasureAttributes: [{
      $Type  : 'UI.ChartMeasureAttributeType',
      Measure: TotalPrice,
      Role   : #Axis1
    }]
  }
};
```

### Chart Types

```cds
// Column Chart
ChartType: #Column

// Bar Chart (horizontal)
ChartType: #Bar

// Line Chart
ChartType: #Line

// Pie Chart
ChartType: #Pie

// Donut Chart
ChartType: #Donut

// Stacked Column
ChartType: #StackedColumn

// Area Chart
ChartType: #Area
```

### Chart with Multiple Measures

```cds
annotate TravelService.TravelAnalytics with @UI.Chart #Revenue: {
  $Type     : 'UI.ChartDefinitionType',
  Title     : 'Revenue Analysis',
  ChartType : #Column,
  Dimensions: [month],
  Measures  : [revenue, cost, profit],
  MeasureAttributes: [
    { Measure: revenue, Role: #Axis1 },
    { Measure: cost, Role: #Axis1 },
    { Measure: profit, Role: #Axis2 }  // Secondary axis
  ]
};
```

### Chart in Object Page

```cds
annotate TravelService.Travel with @UI.Facets: [
  {
    $Type : 'UI.ReferenceFacet',
    Target: '@UI.Chart#BookingAnalysis',
    Label : 'Booking Analysis'
  }
];

annotate TravelService.Travel with @UI.Chart #BookingAnalysis: {
  $Type     : 'UI.ChartDefinitionType',
  Title     : 'Bookings by Status',
  ChartType : #Donut,
  Dimensions: [to_Booking.BookingStatus_code],
  Measures  : [to_Booking.FlightPrice]
};
```

### Micro Charts (Inline Charts)

```cds
annotate TravelService.Travel with @UI: {
  DataPoint #Trend: {
    Value       : TotalPrice,
    TargetValue : budgetAmount,
    Criticality : budgetCriticality
  },
  Chart #BulletChart: {
    $Type            : 'UI.ChartDefinitionType',
    ChartType        : #Bullet,
    Measures         : [TotalPrice],
    MeasureAttributes: [{
      $Type    : 'UI.ChartMeasureAttributeType',
      Measure  : TotalPrice,
      Role     : #Axis1,
      DataPoint: '@UI.DataPoint#Trend'
    }]
  }
};

// Use in LineItem
annotate TravelService.Travel with @UI.LineItem: [
  { Value: TravelID },
  {
    $Type : 'UI.DataFieldForAnnotation',
    Target: '@UI.Chart#BulletChart',
    Label : 'Budget Status'
  }
];
```

---

## Navigation

### Semantic Object Navigation

```cds
// Define semantic object on entity
annotate TravelService.Travel with @Common.SemanticObject: 'Travel';

// Define semantic object on field
annotate TravelService.Travel with {
  to_Agency @Common.SemanticObject: 'TravelAgency';
};
```

### Intent-Based Navigation in LineItem

```cds
annotate TravelService.Travel with @UI.LineItem: [
  {
    $Type         : 'UI.DataFieldWithIntentBasedNavigation',
    Value         : to_Agency.Name,
    SemanticObject: 'TravelAgency',
    Action        : 'display',
    Label         : 'Agency'
  }
];
```

### Navigation with URL

```cds
annotate TravelService.Travel with @UI.LineItem: [
  {
    $Type: 'UI.DataFieldWithUrl',
    Value: to_Agency.Name,
    Url  : to_Agency.WebAddress,
    Label: 'Agency Website'
  }
];
```

### Cross-App Navigation Configuration

```json
// manifest.json
{
  "sap.app": {
    "crossNavigation": {
      "inbounds": {
        "Travel-display": {
          "semanticObject": "Travel",
          "action": "display",
          "signature": {
            "parameters": {
              "TravelID": { "required": true }
            }
          }
        }
      },
      "outbounds": {
        "TravelAgency-display": {
          "semanticObject": "TravelAgency",
          "action": "display"
        }
      }
    }
  }
}
```

---

## Virtual Elements (Computed Fields for UI)

Virtual elements are calculated in handlers and exist only at runtime.

### Defining Virtual Elements

```cds
// In service definition
service TravelService {
  entity Travel as projection on db.Travel {
    *,
    // Virtual elements for UI
    virtual daysUntilStart   : Integer,
    virtual tripDuration     : Integer,
    virtual statusCriticality: Integer,
    virtual isEditable       : Boolean,
    virtual displayStatus    : String
  };
}
```

### Calculating Virtual Elements

```javascript
const cds = require('@sap/cds');

module.exports = class TravelService extends cds.ApplicationService {
  init() {
    const { Travel } = this.entities;

    this.after('READ', Travel, (data) => {
      const travels = Array.isArray(data) ? data : [data];
      const today = new Date();

      travels.forEach(travel => {
        if (!travel) return;

        // Days until trip starts
        if (travel.BeginDate) {
          const beginDate = new Date(travel.BeginDate);
          travel.daysUntilStart = Math.ceil((beginDate - today) / (1000 * 60 * 60 * 24));
        }

        // Trip duration
        if (travel.BeginDate && travel.EndDate) {
          const begin = new Date(travel.BeginDate);
          const end = new Date(travel.EndDate);
          travel.tripDuration = Math.ceil((end - begin) / (1000 * 60 * 60 * 24));
        }

        // Status criticality for colors
        switch (travel.TravelStatus_code) {
          case 'O': travel.statusCriticality = 2; break;  // Orange - Open
          case 'A': travel.statusCriticality = 3; break;  // Green - Accepted
          case 'X': travel.statusCriticality = 1; break;  // Red - Cancelled
          default:  travel.statusCriticality = 0;         // Grey
        }

        // Editable only if Open
        travel.isEditable = travel.TravelStatus_code === 'O';

        // Human-readable status
        const statusMap = { 'O': 'Open', 'A': 'Accepted', 'X': 'Cancelled' };
        travel.displayStatus = statusMap[travel.TravelStatus_code] || 'Unknown';
      });
    });

    return super.init();
  }
}
```

### Using Virtual Elements in Annotations

```cds
annotate TravelService.Travel with @UI: {
  LineItem: [
    { Value: TravelID },
    { Value: Description },
    { 
      Value      : TravelStatus_code,
      Criticality: statusCriticality  // Virtual field for color
    },
    { Value: daysUntilStart, Label: 'Days Until Start' },
    { Value: tripDuration, Label: 'Duration (Days)' }
  ],
  HeaderFacets: [
    {
      $Type : 'UI.ReferenceFacet',
      Target: '@UI.DataPoint#Duration'
    }
  ],
  DataPoint #Duration: {
    Value      : tripDuration,
    Title      : 'Trip Duration',
    Description: 'Days'
  }
};

// Field control using virtual element
annotate TravelService.Travel with {
  Description @Common.FieldControl: { $edmJson: { 
    $If: [{ $Path: 'isEditable' }, 3, 1] 
  }};
};
```

---

## Field Criticality (Colored Fields)

### Status Field with Criticality

```cds
annotate TravelService.Travel with @UI.LineItem: [
  {
    $Type      : 'UI.DataField',
    Value      : TravelStatus_code,
    Criticality: statusCriticality,  // Points to Integer field (0-3)
    ![@UI.Importance]: #High
  }
];
```

### DataField with CriticalityRepresentation

```cds
annotate TravelService.Travel with @UI.LineItem: [
  {
    $Type                    : 'UI.DataField',
    Value                    : TravelStatus_code,
    Criticality              : statusCriticality,
    CriticalityRepresentation: #WithIcon  // Shows icon alongside color
  }
];

// Options: #WithIcon, #WithoutIcon (default)
```

### Criticality in DataPoint

```cds
annotate TravelService.Travel with @UI: {
  DataPoint #Budget: {
    Value      : TotalPrice,
    Title      : 'Budget Used',
    Criticality: budgetCriticality,
    CriticalityCalculation: {
      ImprovementDirection: #Minimize,  // Lower is better
      ToleranceRangeLowValue: 0,
      ToleranceRangeHighValue: 5000,
      DeviationRangeLowValue: 5000,
      DeviationRangeHighValue: 10000
    }
  }
};
```

### Criticality Calculation (Automatic)

Instead of virtual fields, let Fiori calculate criticality:

```cds
annotate TravelService.Travel with @UI.DataPoint #AutoCriticality: {
  Value                 : TotalPrice,
  Title                 : 'Total Price',
  CriticalityCalculation: {
    ImprovementDirection     : #Minimize,  // Or #Maximize, #Target
    // For #Minimize: Green < Tolerance < Orange < Deviation < Red
    ToleranceRangeHighValue  : 5000,   // Green threshold
    DeviationRangeHighValue  : 10000   // Orange threshold (above = Red)
  }
};
```

---

## Draft Handling (UI Perspective)

### Enable Draft with Annotations

```cds
// In service definition
service TravelService {
  @odata.draft.enabled
  entity Travel as projection on db.Travel;
}
```

### Draft Indicator in Table

The draft indicator appears automatically. Customize with:

```cds
annotate TravelService.Travel with @Common: {
  DraftRoot: {
    ActivationAction      : 'TravelService.draftActivate',
    EditAction            : 'TravelService.draftEdit',
    PreparationAction     : 'TravelService.draftPrepare',
    ValidationFunction    : 'TravelService.draftValidate'
  }
};
```

### Draft Edit Flow Customization

```json
// manifest.json
{
  "sap.ui5": {
    "routing": {
      "targets": {
        "TravelObjectPage": {
          "options": {
            "settings": {
              "editableHeaderContent": true,
              "showDraftToggle": true,
              "stickyEditMode": true
            }
          }
        }
      }
    }
  }
}
```

### Showing Draft Status in Header

```cds
annotate TravelService.Travel with @UI.HeaderInfo: {
  TypeName      : 'Travel',
  TypeNamePlural: 'Travels',
  Title         : { Value: Description },
  Description   : { Value: TravelID }
  // Draft status is shown automatically when @odata.draft.enabled
};
```

### Conditional Editability with UpdateRestrictions

**Pattern:** Disable editing (hide Edit button) based on entity status or state.

**Use Case:** RMAs that are "Approved" or "Rejected" should not be editable. Only "Submitted" RMAs can be modified.

**Solution:** Use `@Capabilities.UpdateRestrictions` with a conditional `Updatable` property:

```cds
// Hide Edit button when status is NOT SUBMITTED
annotate CustomerPortalService.RMAs with @Capabilities: {
  UpdateRestrictions: [{
    Updatable: {
      $edmJson: {
        $Eq: [{ $Path: 'status_ID' }, 'aaaaaaaa-aaaa-1111-1111-111111111111']  // SUBMITTED
      }
    }
  }]
};

// Hide Add/Edit/Delete buttons on child items when parent status is NOT SUBMITTED
annotate CustomerPortalService.RMAItems with @Capabilities: {
  UpdateRestrictions: [{
    Updatable: {
      $edmJson: {
        $Eq: [{ $Path: 'rma/status_ID' }, 'aaaaaaaa-aaaa-1111-1111-111111111111']
      }
    }
  }],
  InsertRestrictions: [{
    Insertable: {
      $edmJson: {
        $Eq: [{ $Path: 'rma/status_ID' }, 'aaaaaaaa-aaaa-1111-1111-111111111111']
      }
    }
  }],
  DeleteRestrictions: [{
    Deletable: {
      $edmJson: {
        $Eq: [{ $Path: 'rma/status_ID' }, 'aaaaaaaa-aaaa-1111-1111-111111111111']
      }
    }
  }]
};
```

**Benefits:**
- ✅ Edit button grayed out/hidden for non-editable records
- ✅ Users can still preview/view data in read-only mode
- ✅ No error messages when users try to edit
- ✅ Clean, professional UX
- ✅ Backend validation still applies as safety net

**Notes:**
- Supports path expressions like `rma/status_ID` for parent status checks
- Works with `$edmJson` conditional expressions
- Always pair with backend `before('UPDATE')` validation for security

---

## Selection and Presentation Variants

### SelectionVariant (Default Filters)

```cds
annotate TravelService.Travel with @UI.SelectionVariant #OpenTravels: {
  $Type        : 'UI.SelectionVariantType',
  Text         : 'Open Travels',
  SelectOptions: [
    {
      PropertyName: TravelStatus_code,
      Ranges      : [{
        Sign  : #I,  // Include
        Option: #EQ,
        Low   : 'O'
      }]
    }
  ]
};

annotate TravelService.Travel with @UI.SelectionVariant #Recent: {
  $Type        : 'UI.SelectionVariantType',
  Text         : 'Recent (Last 30 Days)',
  SelectOptions: [
    {
      PropertyName: createdAt,
      Ranges      : [{
        Sign  : #I,
        Option: #GE,
        Low   : '2024-01-01'  // Or use dynamic value
      }]
    }
  ]
};
```

### PresentationVariant (Default Sort/Group)

```cds
annotate TravelService.Travel with @UI.PresentationVariant: {
  $Type         : 'UI.PresentationVariantType',
  Text          : 'Default View',
  SortOrder     : [
    { Property: BeginDate, Descending: false },
    { Property: TravelID, Descending: true }
  ],
  GroupBy       : [TravelStatus_code],
  Visualizations: ['@UI.LineItem']
};

// Named variant
annotate TravelService.Travel with @UI.PresentationVariant #ByAgency: {
  $Type    : 'UI.PresentationVariantType',
  Text     : 'Grouped by Agency',
  GroupBy  : [to_Agency_AgencyID],
  SortOrder: [{ Property: TotalPrice, Descending: true }]
};
```

### SelectionPresentationVariant (Combined)

```cds
annotate TravelService.Travel with @UI.SelectionPresentationVariant #OpenByDate: {
  $Type              : 'UI.SelectionPresentationVariantType',
  Text               : 'Open Travels by Date',
  SelectionVariant   : {
    SelectOptions: [{
      PropertyName: TravelStatus_code,
      Ranges: [{ Sign: #I, Option: #EQ, Low: 'O' }]
    }]
  },
  PresentationVariant: {
    SortOrder     : [{ Property: BeginDate, Descending: false }],
    Visualizations: ['@UI.LineItem']
  }
};
```

### Using Variants in Manifest

```json
{
  "sap.ui5": {
    "routing": {
      "targets": {
        "TravelList": {
          "options": {
            "settings": {
              "defaultTemplateAnnotationPath": "com.sap.vocabularies.UI.v1.SelectionPresentationVariant#OpenByDate"
            }
          }
        }
      }
    }
  }
}
```

---

## Building Blocks

### Field

The Field building block enables you to render a property that is configured as part of the service metadata.

```cds
@Common.Label: 'Description'
Description : String(1024);
```

#### Avatar

```cds
Icon     : String @(UI: {IsImageURL: true});
ImageUrl : String @(UI: {IsImageURL: true});
```

#### Business Object Status

```cds
annotate service.Travel with @(UI: {
  FieldGroup #TravelData: {Data: [
    {Value: TravelID},
    {Value: to_Agency_AgencyID},
    {Value: BeginDate},
    {Value: EndDate}
  ]},
  FieldGroup #ApprovalData: {Data: [
    {
      $Type      : 'UI.DataField',
      Value      : TravelStatus_code,
      Criticality: TravelStatus.criticality,
      Label      : 'Status'
    },
    {Value: BookingFee},
    {Value: TotalPrice}
  ]}
});
```

#### Checkbox

```cds
extend entity TravelService.Travel with {
  Approved : Boolean;
};
```

#### Contact

**BEST PRACTICE:** Always implement Contact Cards for customer/organization/contact entities.

```cds
annotate service.Customer with @(
  Communication.Contact: {
    fn   : companyName,
    org  : contactPerson,
    photo: 'sap-icon://customer',
    tel  : [{ type: #work, uri: phone }],
    email: [{ type: #work, address: email }],
    adr  : [{
      type   : #work,
      code   : postalCode,
      country: countryCode_code,
      locality: city
    }]
  },
  Common.IsNaturalPerson: false
);

annotate service.Customer with {
  email @(Communication.IsEmailAddress: true);
  phone @(Communication.IsPhoneNumber: true);
};

// Display in parent entity
annotate service.Leads with @UI.FieldGroup #LeadDetails: {
  Data: [{
    $Type : 'UI.DataFieldForAnnotation',
    Target: 'customer/@Communication.Contact',
    Label : 'Company'
  }]
};
```

#### Data Point

```cds
DataPoint #Recommendation: {
  Value        : Recommendation,
  TargetValue  : 100.0,
  Title        : 'Recommendation',
  Visualization: #Progress
};
```

#### Date/Time Pickers

```cds
BeginDate    : Date     @mandatory;
EndDate      : Date     @mandatory;
ReminderTime : DateTime;
StartTime    : Time;
```

#### Input with Value Help

*Dialog Value Help with Typeahead*

```cds
annotate RootEntity with {
  @(Common: {ValueList: {
    CollectionPath: 'BusinessPartnerAddress',
    Parameters    : [
      {
        $Type            : 'Common.ValueListParameterInOut',
        LocalDataProperty: valueHelpField,
        ValueListProperty: 'BusinessPartner',
        ![@UI.Importance]: #High
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'FullName'
      }
    ]
  }})
  valueHelpField;
};
```

#### Value Help with Dropdown (Fixed Values)

**Use `ValueListWithFixedValues: true` when you have a small, fixed set of values (typically < 15 entries).** This displays a dropdown/select list directly in the field instead of opening a dialog, providing faster selection for code lists, status values, and small reference data.

```cds
annotate RootEntity with {
  @(Common: {
    ValueListWithFixedValues: true,
    ValueList: {
      CollectionPath: 'StatusCodes',
      Parameters    : [{
        $Type            : 'Common.ValueListParameterInOut',
        LocalDataProperty: status,
        ValueListProperty: 'code'
      }]
    }
  })
  status;
};
```

**When to use dropdown vs dialog:**
- ✅ **Dropdown (`ValueListWithFixedValues: true`)**: Status codes, return reasons, priority levels, boolean-like choices, small code lists (5-15 entries)
- ✅ **Dialog (regular `ValueList`)**: Customers, products, large master data, entities that require search/filtering

#### Inline Table Editing with Associations (Foreign Keys)

**For editing association fields inline in tables, use the Foreign Key field, not the association itself.**

```cds
// WRONG - Using the association directly
annotate Service.RMAItems with @UI.LineItem: [
  {
    $Type: 'UI.DataField',
    Value: reason,  // ❌ This won't work for inline editing
    Label: 'Return Reason'
  }
];

// CORRECT - Use the _ID foreign key field
annotate Service.RMAItems with @UI.LineItem: [
  {
    $Type: 'UI.DataField',
    Value: reason_ID,  // ✅ Use FK for editing
    Label: 'Return Reason'
  }
];
```

**Critical: Text Arrangement for Clean Display**

Always set `TextArrangement: #TextOnly` (or `#TextFirst`) to display friendly names, NOT raw UUIDs:

```cds
reason @Common: {
  Label: 'Return Reason',
  FieldControl: #Optional,
  ValueListWithFixedValues: true,
  ValueList: {
    CollectionPath: 'ReturnReasons',
    Parameters: [
      {
        $Type: 'Common.ValueListParameterInOut',
        LocalDataProperty: reason_ID,      // Use FK field
        ValueListProperty: 'ID'             // Map to ReturnReasons.ID
      },
      {
        $Type: 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'name'           // Show friendly name
      },
      {
        $Type: 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'description'    // Show description
      }
    ]
  },
  Text: reason.name,                        // Display text reference
  TextArrangement: #TextOnly                // ✅ Show only name, not UUID
};
```

**Text Arrangement Options:**
- `#TextOnly` - Display only the friendly name (clean, recommended for dropdowns)
- `#TextFirst` - Display name first, then ID: "Defective (uuid...)"
- `#TextLast` - Display ID first, then name (messy, avoid for UX)
- `#TextSeparate` - Show in separate columns

**Important: UUID Patterns in Seed Data**

⚠️ **AVOID**: Using generic UUID patterns like `11111111-1111-1111-1111-111111111111`

```javascript
// BAD - Creates messy UX, hard to debug
const STATUS = {
  SUBMITTED: 'aaaaaaaa-aaaa-1111-1111-111111111111',
  UNDER_REVIEW: 'bbbbbbbb-bbbb-2222-2222-222222222222',
  APPROVED: 'cccccccc-cccc-3333-3333-333333333333'
};
```

✅ **GOOD**: Use semantic codes or let database generate UUIDs

```javascript
// Option 1: Use semantic codes
const STATUS = {
  SUBMITTED: 'status-submitted',
  UNDER_REVIEW: 'status-under-review',
  APPROVED: 'status-approved'
};

// Option 2: Use database-generated UUIDs and reference in code by semantic name
// The UUIDs are generated on first insert, then referenced by the code column
```

#### Value Help with Validation

```cds
annotate RootEntity with {
  @(Common: {
    Text                  : _Partner.Name,
    ValueListForValidation: '',
    ValueList             : {
      CollectionPath: 'BusinessPartners',
      Parameters    : [{
        $Type            : 'Common.ValueListParameterInOut',
        LocalDataProperty: partner_ID,
        ValueListProperty: 'ID'
      }]
    }
  })
  partner_ID;
};
```

#### Link with URL

```cds
annotate service.TravelAgency with @UI.FieldGroup #Link: {
  Data: [{
    $Type: 'UI.DataFieldWithUrl',
    Value: Name,
    Url  : WebAddress
  }]
};
```

#### Link with Quick View

```cds
annotate service.TravelAgency with @UI: {
  QuickViewFacets: [{
    $Type : 'UI.ReferenceFacet',
    Label : 'Travel Agency',
    Target: '@UI.FieldGroup#QuickViewContent'
  }],
  FieldGroup #QuickViewContent: {
    Data: [
      {Value: Name},
      {Value: City},
      {Value: CountryCode_code}
    ]
  }
};
```

#### Masked Field

```cds
CreditCardNumber : String @Common: {Masked: true};
```

#### Multi-Line Text

```cds
@UI.MultiLineText
TravelDetails : String(1024);
```

#### Number with Currency/Unit

```cds
FlightPrice : Decimal(10, 2) @Measures.ISOCurrency: CurrencyCode_code;
Distance    : Integer        @Measures.Unit: DistanceUnit;
```

#### Rating Indicator

```cds
DataPoint #Rating: {
  Value        : Rating,
  TargetValue  : 5.0,
  Title        : 'Rating',
  Visualization: #Rating
};
```

### Filter Bar

```cds
annotate service.Travel with @UI.SelectionFields: [
  TravelID,
  to_Agency_AgencyID,
  TravelStatus_code,
  BeginDate,
  EndDate
];
```

#### Default Filter Values

```cds
annotate TravelService.Travel with @UI.SelectionVariant: {
  $Type        : 'UI.SelectionVariantType',
  SelectOptions: [
    {
      PropertyName: BeginDate,
      Ranges      : [{
        Sign  : #I,
        Option: #GE,
        Low   : '2025-01-01'
      }]
    },
    {
      PropertyName: TravelStatus_code,
      Ranges      : [{
        Sign  : #I,
        Option: #EQ,
        Low   : 'O'
      }]
    }
  ]
};
```

### Micro Chart

```cds
Chart #HarveyBall: {
  $Type            : 'UI.ChartDefinitionType',
  Title            : 'Credit Limit',
  ChartType        : #Pie,
  Measures         : [ExposureAmount],
  MeasureAttributes: [{
    $Type    : 'UI.ChartMeasureAttributeType',
    Measure  : ExposureAmount,
    Role     : #Axis1,
    DataPoint: '@UI.DataPoint#CreditLimit'
  }]
},
DataPoint #CreditLimit: {
  Value       : ExposureAmount,
  MaximumValue: CreditLimit,
  Criticality : IsAboveThreshold
};
```

---

## Side Effects

Side effects define how changes to one field affect other fields or data.

### Single Source Property

```cds
annotate RootEntity with @Common.SideEffects #quantity: {
  SourceProperties: [quantity],
  TargetProperties: ['totalPrice', 'discount']
};
```

### With Trigger Action

```cds
annotate RootEntity with @Common.SideEffects #priceCalc: {
  SourceProperties: [unitPrice],
  TargetProperties: ['totalPrice'],
  TriggerAction   : 'Service.recalculatePrice'
};
```

### Multiple Source Properties

```cds
annotate RootEntity with @Common.SideEffects #dateRange: {
  SourceProperties: [startDate, endDate],
  TargetProperties: ['duration', 'totalCost'],
  TriggerAction   : 'Service.validateDates'
};
```

### On Source Entity (Table Changes)

```cds
annotate RootEntity with @Common.SideEffects #items: {
  SourceEntities  : [items],  // Composition
  TargetProperties: ['totalAmount', 'itemCount']
};
```

### On Bound Action

```cds
@(
  Common.SideEffects: { TargetProperties: ['_it/*'] },
  cds.odata.bindingparameter.name: '_it',
  Core.OperationAvailable: _it.IsEditable
)
action approve();
```

### Refresh Value Help Cache

```cds
@(
  Common.SideEffects #InvalidateCache: {
    TargetProperties: ['_it/PartnerID'],
    TargetEntities  : ['/Service.EntityContainer/Partners']
  },
  cds.odata.bindingparameter.name: '_it'
)
action updatePartner();
```

---

## Extensions

### Accessing ExtensionAPI

```ts
import type ObjectPageExtensionAPI from "sap/fe/templates/ObjectPage/ExtensionAPI";

const customImplementation = {
  accept(this: ObjectPageExtensionAPI): void {
    this.refresh();
  }
};

export default customImplementation;
```

### Loading Custom Controller in XML

```xml
<core:FragmentDefinition xmlns:core="sap.ui.core" xmlns="sap.m">
  <HBox core:require="{handler: 'myApp/ext/myHandler'}">
    <Button text="Accept" press="handler.accept" type="Positive" />
  </HBox>
</core:FragmentDefinition>
```

### Controller Extension

```ts
import BaseControllerExtension from "sap/fe/core/controllerextensions/BaseControllerExtension";
import type ObjectPageController from "sap/fe/templates/ObjectPage/ObjectPageController.controller";

export default class OPExtend extends BaseControllerExtension<ObjectPageController> {
  static overrides = BaseControllerExtension.createExtensionOverrides<OPExtend>({
    onInit(): void {
      const extensionAPI = this.base.getExtensionAPI();
    },
    editFlow: {
      onBeforeSave(): Promise<void> {
        return Promise.resolve();
      }
    }
  });

  public formatMyField(): string {
    return "";
  }

  public accept(): void {
    const extensionAPI = this.base.getExtensionAPI();
  }
}
```

### Defining Extension in Manifest

```json
{
  "sap.ui5": {
    "extends": {
      "extensions": {
        "sap.ui.controllerExtensions": {
          "sap.fe.templates.ListReport.ListReportController": {
            "controllerName": "myApp.ext.LRExtend"
          },
          "sap.fe.templates.ObjectPage.ObjectPageController#myAppID::CustomerDetails": {
            "controllerNames": ["myApp.ext.OPExtend", "myApp.ext.CustomerExtend"]
          }
        }
      }
    }
  }
}
```

### Using Extensions in Fragments

```xml
<HBox>
  <Button text="Accept" press=".extension.myApp.ext.OPExtend.accept" type="Positive" />
  <Text text="{path: 'Amount', formatter:'.extension.myApp.ext.OPExtend.myFormatter' }" />
</HBox>
```

---

## Custom Header Example

### Manifest Configuration

```json
{
  "sap.ui5": {
    "extends": {
      "extensions": {
        "sap.ui.controllerExtensions": {
          "sap.fe.templates.ListReport.ListReportController": {
            "controllerName": "myApp.ext.customHeader.CustomHeaderExtend"
          }
        }
      }
    },
    "routing": {
      "targets": {
        "LeadsList": {
          "options": {
            "settings": {
              "content": {
                "header": {
                  "visible": true,
                  "customHeader": {
                    "expandedHeaderFragment": "myApp.ext.customHeader.Expanded",
                    "collapsedHeaderFragment": "myApp.ext.customHeader.Collapsed"
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

### Expanded Header Fragment

```xml
<core:FragmentDefinition xmlns:core="sap.ui.core" xmlns="sap.m">
  <HBox class="sapUiMediumMargin">
    <GenericTile
      header="Total Leads"
      subheader="Active leads"
      press=".extension.myApp.ext.customHeader.CustomHeaderExtend.onTotalPress"
    >
      <TileContent unit="Leads">
        <NumericContent value="{headerModel>/totalLeads}" withMargin="false" />
      </TileContent>
    </GenericTile>
  </HBox>
</core:FragmentDefinition>
```

### Controller Implementation

```ts
import BaseControllerExtension from "sap/fe/core/controllerextensions/BaseControllerExtension";
import JSONModel from "sap/ui/model/json/JSONModel";

export default class CustomHeaderExtend extends BaseControllerExtension {
  private headerModel: JSONModel;

  constructor() {
    super();
    setTimeout(() => this.initializeHeaderData(), 0);
  }

  private initializeHeaderData(): void {
    this.headerModel = new JSONModel({ totalLeads: 0 });
    const oView = this.getView();
    if (oView) {
      oView.setModel(this.headerModel, "headerModel");
      this.loadHeaderData();
    }
  }

  private loadHeaderData(): void {
    fetch('/odata/v4/my-service/Leads?$count=true')
      .then(res => res.json())
      .then(data => {
        this.headerModel.setProperty("/totalLeads", data['@odata.count'] || 0);
      });
  }

  public onTotalPress(): void {
    const extensionAPI = (this as any).base?.getExtensionAPI?.();
    if (extensionAPI) {
      extensionAPI.setFilterValues("status", "EQ", "New");
      setTimeout(() => extensionAPI.search?.(), 100);
    }
  }
}
```

---

## Quick Reference

### Annotation Prefixes

| Prefix | Purpose |
|--------|---------|
| `@UI` | User interface annotations |
| `@Common` | Common annotations (labels, value helps) |
| `@Communication` | Contact/address annotations |
| `@Measures` | Units and currencies |
| `@Core` | Core vocabulary (computed, immutable) |
| `@Capabilities` | OData capabilities |
| `@Aggregation` | Analytical annotations |

### Common @UI Annotations

| Annotation | Purpose |
|------------|---------|
| `@UI.LineItem` | Table columns |
| `@UI.HeaderInfo` | Object page header |
| `@UI.HeaderFacets` | Header KPIs/cards |
| `@UI.Facets` | Object page sections |
| `@UI.FieldGroup` | Group of fields |
| `@UI.SelectionFields` | Filter bar fields |
| `@UI.DataPoint` | KPI/progress indicator |
| `@UI.Chart` | Chart definition |
| `@UI.Identification` | Header actions |
| `@UI.Hidden` | Hide field |
| `@UI.Importance` | Column visibility |

### Common @Common Annotations

| Annotation | Purpose |
|------------|---------|
| `@Common.Label` | Field label |
| `@Common.Text` | Display text for key |
| `@Common.TextArrangement` | How to show key+text |
| `@Common.ValueList` | Value help definition |
| `@Common.ValueListWithFixedValues` | Dropdown |
| `@Common.ValueListForValidation` | Validate input |
| `@Common.FieldControl` | Editable/readonly/hidden |
| `@Common.SemanticObject` | Navigation target |
| `@Common.SideEffects` | Auto-refresh |

### Text Arrangement Options

```cds
@Common.TextArrangement: #TextOnly      // Show only text
@Common.TextArrangement: #TextFirst     // Text (Key)
@Common.TextArrangement: #TextLast      // Key (Text)
@Common.TextArrangement: #TextSeparate  // Text and Key separate
```

### Field Control Values

```cds
@Common.FieldControl: #Mandatory  // 7 - Required
@Common.FieldControl: #Optional   // 3 - Editable (default)
@Common.FieldControl: #ReadOnly   // 1 - Display only
@Common.FieldControl: #Hidden     // 0 - Hidden
```

### Criticality Values

| Value | Color | Use |
|-------|-------|-----|
| 0 | Grey | Neutral |
| 1 | Red | Negative/Error |
| 2 | Orange | Critical/Warning |
| 3 | Green | Positive/Success |
| 5 | Blue | New Item |

### DataField Types

| Type | Use Case |
|------|----------|
| `UI.DataField` | Standard field |
| `UI.DataFieldForAction` | Action button |
| `UI.DataFieldForAnnotation` | Reference another annotation |
| `UI.DataFieldWithUrl` | Clickable URL |
| `UI.DataFieldWithIntentBasedNavigation` | Cross-app navigation |
| `UI.DataFieldForIntentBasedNavigation` | Navigation without value |

### Chart Types

| Type | Description |
|------|-------------|
| `#Column` | Vertical bars |
| `#Bar` | Horizontal bars |
| `#Line` | Line chart |
| `#Pie` | Pie chart |
| `#Donut` | Donut chart |
| `#StackedColumn` | Stacked columns |
| `#Area` | Area chart |
| `#Bullet` | Bullet chart (micro) |

### Value Help Parameter Types

| Type | Behavior |
|------|----------|
| `ValueListParameterIn` | Filter value help by local value |
| `ValueListParameterOut` | Fill local field from selection |
| `ValueListParameterInOut` | Both In and Out |
| `ValueListParameterDisplayOnly` | Show in list, don't map |
| `ValueListParameterFilterOnly` | Filter only, don't show |

---

## Validation Checklist

Generated annotations should include:

- [ ] `@UI.HeaderInfo` with Title and Description
- [ ] `@UI.LineItem` with proper column order and importance
- [ ] `@UI.SelectionFields` for filter bar
- [ ] `@UI.Facets` with logical section grouping
- [ ] `@Common.Label` for all fields (human-friendly)
- [ ] `@Common.Text` and `@Common.TextArrangement` for code fields
- [ ] `@Common.ValueList` for foreign keys (large/master data)
- [ ] `@Common.ValueListWithFixedValues: true` for small fixed code lists (dropdown instead of dialog)
- [ ] `@Measures.ISOCurrency` or `@Measures.Unit` for amounts
- [ ] Criticality for status fields
- [ ] `@UI.Hidden` for technical fields (IDs, foreign keys)
- [ ] `@Common.SideEffects` for dependent field updates
- [ ] Actions with `@Core.OperationAvailable` conditions

---

## Key Reminders

1. **Labels everywhere** — Never show technical names to users
2. **Value helps always** — Every foreign key needs a value help
3. **Dropdown for small lists** — Use `ValueListWithFixedValues: true` for fixed/small code lists (< 15 entries) to show dropdown instead of dialog
4. **Dialog for large lists** — Use regular `ValueList` for large master data that needs search/filtering
5. **Text arrangements** — Show names, not codes
6. **Criticality for status** — Use colors to convey meaning
7. **Hide technical fields** — UUIDs and FKs should be hidden
8. **Side effects** — Auto-refresh dependent data
9. **Importance matters** — Control responsive column visibility
10. **Contact cards** — Professional display for customer data
11. **Validation** — Use ValueListForValidation for data quality
12. **Actions visible** — Use @Core.OperationAvailable for conditional display
