using RMAService as service from '../srv/rma-service';

////////////////////////////////////////////////////////////////////////////
//
// Shared UI Annotations for RMAService
// Common annotations used across multiple Fiori applications
//
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
//
// RMAs - Main Entity
//
////////////////////////////////////////////////////////////////////////////

annotate service.RMAs with @(
    // Default LineItem - required for List Report to load
    UI.SelectionFields : [
        rmaNumber,
        status_code,
        customer_ID,
        rmaDate
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : rmaNumber,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : customer.companyName,
            Label : '{i18n>customer}',
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : status_code,
            Criticality : criticality,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : totalAmount,
            ![@UI.Importance] : #Medium
        },
        {
            $Type : 'UI.DataField',
            Value : rmaDate,
            ![@UI.Importance] : #Medium
        }
    ],
    UI.Identification : [
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'RMAService.approve',
            Label : '{i18n>approve}'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'RMAService.rejectRMA',
            Label : '{i18n>reject}'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'RMAService.markShipped',
            Label : '{i18n>markShipped}'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'RMAService.markReceived',
            Label : '{i18n>markReceived}'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'RMAService.completeInspection',
            Label : '{i18n>completeInspection}'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'RMAService.resolveRMA',
            Label : '{i18n>resolveRMA}'
        }
    ],
    UI.HeaderInfo : {
        TypeName : '{i18n>rma}',
        TypeNamePlural : '{i18n>rmas}',
        Title : { Value : rmaNumber },
        Description : { Value : customer.companyName }
    },
    UI.HeaderFacets : [
        {
            $Type : 'UI.ReferenceFacet',
            Target : '@UI.DataPoint#Status',
            Label : '{i18n>status}'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target : '@UI.DataPoint#TotalAmount',
            Label : '{i18n>totalAmount}'
        }
    ],
    UI.DataPoint #Status : {
        Value : status_code,
        Title : '{i18n>status}',
        Criticality : criticality
    },
    UI.DataPoint #TotalAmount : {
        Value : totalAmount,
        Title : '{i18n>totalAmount}'
    },
    UI.Facets : [
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>generalInformation}',
            ID : 'GeneralInfo',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#GeneralInfo',
                    Label : '{i18n>details}'
                }
            ]
        },
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>customerDetails}',
            ID : 'CustomerInfo',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#CustomerInfo',
                    Label : '{i18n>customerInformation}'
                }
            ]
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : '{i18n>returnItems}',
            Target : 'items/@UI.LineItem'
        },
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>approvalInformation}',
            ID : 'ApprovalInfo',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#ApprovalInfo',
                    Label : '{i18n>approvalDetails}'
                }
            ]
        }
    ],
    UI.FieldGroup #GeneralInfo : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : rmaNumber
            },
            {
                $Type : 'UI.DataField',
                Value : rmaDate
            },
            {
                $Type : 'UI.DataField',
                Value : expectedReturnDate
            },
            {
                $Type : 'UI.DataField',
                Value : status_code,
                Criticality : criticality
            },
            {
                $Type : 'UI.DataField',
                Value : resolutionType
            },
            {
                $Type : 'UI.DataField',
                Value : resolutionNotes,
                ![@UI.MultiLineText] : true
            }
        ]
    },
    UI.FieldGroup #CustomerInfo : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : customer_ID,
                Label : '{i18n>customer}'
            },
            {
                $Type : 'UI.DataField',
                Value : customer.companyName,
                Label : '{i18n>companyName}'
            },
            {
                $Type : 'UI.DataField',
                Value : customer.contactName,
                Label : '{i18n>contactName}'
            },
            {
                $Type : 'UI.DataField',
                Value : customer.email,
                Label : '{i18n>email}'
            },
            {
                $Type : 'UI.DataField',
                Value : customer.phone,
                Label : '{i18n>phone}'
            }
        ]
    },
    UI.FieldGroup #ApprovalInfo : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : approvedBy
            },
            {
                $Type : 'UI.DataField',
                Value : approvedDate
            },
            {
                $Type : 'UI.DataField',
                Value : rejectionReason,
                ![@UI.MultiLineText] : true
            },
            {
                $Type : 'UI.DataField',
                Value : trackingNumber
            },
            {
                $Type : 'UI.DataField',
                Value : receivedDate
            },
            {
                $Type : 'UI.DataField',
                Value : resolutionDate
            }
        ]
    }
);

// Field-level annotations for RMAs
annotate service.RMAs with {
    ID @(
        UI.Hidden,
        Common.Label : '{i18n>ID}'
    );
    rmaNumber @Common.Label : '{i18n>rmaNumber}';
    rmaDate @Common.Label : '{i18n>rmaDate}';
    customer @(
        Common.Label : '{i18n>customer}',
        Common.Text : customer.companyName,
        Common.TextArrangement : #TextOnly,
        Common.ValueList : {
            CollectionPath : 'Customers',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : customer_ID,
                    ValueListProperty : 'ID'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'companyName'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'contactName'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'email'
                }
            ]
        }
    );
    status @(
        Common.Label : '{i18n>status}',
        Common.Text : status.name,
        Common.TextArrangement : #TextOnly,
        Common.ValueListWithFixedValues : true,
        Common.ValueList : {
            CollectionPath : 'RMAStatus',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : status_code,
                    ValueListProperty : 'code'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name'
                }
            ]
        }
    );
    expectedReturnDate @Common.Label : '{i18n>expectedReturnDate}';
    receivedDate @Common.Label : '{i18n>receivedDate}';
    resolutionDate @Common.Label : '{i18n>resolutionDate}';
    totalAmount @(
        Common.Label : '{i18n>totalAmount}',
        Measures.ISOCurrency : currency
    );
    currency @(
        Common.Label : '{i18n>currency}',
        UI.Hidden : true
    );
    resolutionType @(
        Common.Label : '{i18n>resolutionType}',
        Common.ValueListWithFixedValues : true
    );
    resolutionNotes @Common.Label : '{i18n>resolutionNotes}';
    approvedBy @Common.Label : '{i18n>approvedBy}';
    approvedDate @Common.Label : '{i18n>approvedDate}';
    rejectionReason @Common.Label : '{i18n>rejectionReason}';
    trackingNumber @Common.Label : '{i18n>trackingNumber}';
    criticality @(
        UI.Hidden : true,
        Common.Label : '{i18n>criticality}',
        Core.Computed : true
    );
    // Action availability virtual fields
    canApprove @(UI.Hidden : true, Core.Computed : true);
    canReject @(UI.Hidden : true, Core.Computed : true);
    canMarkShipped @(UI.Hidden : true, Core.Computed : true);
    canMarkReceived @(UI.Hidden : true, Core.Computed : true);
    canCompleteInspection @(UI.Hidden : true, Core.Computed : true);
    canResolve @(UI.Hidden : true, Core.Computed : true);
};

////////////////////////////////////////////////////////////////////////////
//
// RMA Items - Line Items
//
////////////////////////////////////////////////////////////////////////////

annotate service.RMAItems with @(
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : product.name,
            Label : '{i18n>product}',
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : quantity,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : unitPrice,
            ![@UI.Importance] : #Medium
        },
        {
            $Type : 'UI.DataField',
            Value : totalPrice,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : returnReason.name,
            Label : '{i18n>returnReason}',
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : condition_code,
            ![@UI.Importance] : #Medium
        },
        {
            $Type : 'UI.DataField',
            Value : inspectionNotes,
            ![@UI.Importance] : #Low
        }
    ],
    UI.HeaderInfo : {
        TypeName : '{i18n>rmaItem}',
        TypeNamePlural : '{i18n>rmaItems}',
        Title : { Value : product.name }
    },
    UI.Facets : [
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>itemDetails}',
            ID : 'ItemDetails',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#ItemDetails',
                    Label : '{i18n>details}'
                }
            ]
        },
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>inspectionDetails}',
            ID : 'InspectionDetails',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#InspectionDetails',
                    Label : '{i18n>inspection}'
                }
            ]
        }
    ],
    UI.FieldGroup #ItemDetails : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : product_ID,
                Label : '{i18n>product}'
            },
            {
                $Type : 'UI.DataField',
                Value : quantity
            },
            {
                $Type : 'UI.DataField',
                Value : unitPrice
            },
            {
                $Type : 'UI.DataField',
                Value : totalPrice
            },
            {
                $Type : 'UI.DataField',
                Value : returnReason_code,
                Label : '{i18n>returnReason}'
            }
        ]
    },
    UI.FieldGroup #InspectionDetails : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : condition
            },
            {
                $Type : 'UI.DataField',
                Value : inspectionDate
            },
            {
                $Type : 'UI.DataField',
                Value : inspectionNotes,
                ![@UI.MultiLineText] : true
            },
            {
                $Type : 'UI.DataField',
                Value : approved
            }
        ]
    }
);

// Field-level annotations for RMAItems
annotate service.RMAItems with {
    ID @(
        UI.Hidden,
        Common.Label : '{i18n>ID}'
    );
    product @(
        Common.Label : '{i18n>product}',
        Common.Text : product.name,
        Common.TextArrangement : #TextOnly,
        Common.ValueList : {
            CollectionPath : 'Products',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : product_ID,
                    ValueListProperty : 'ID'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'productNumber'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'price'
                }
            ]
        }
    );
    quantity @Common.Label : '{i18n>quantity}';
    unitPrice @(
        Common.Label : '{i18n>unitPrice}',
        Measures.ISOCurrency : rma.currency
    );
    totalPrice @(
        Common.Label : '{i18n>totalPrice}',
        Measures.ISOCurrency : rma.currency
    );
    returnReason @(
        Common.Label : '{i18n>returnReason}',
        Common.Text : returnReason.name,
        Common.TextArrangement : #TextOnly,
        Common.ValueListWithFixedValues : true,
        Common.ValueList : {
            CollectionPath : 'ReturnReasons',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : returnReason_code,
                    ValueListProperty : 'code'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name'
                }
            ]
        }
    );
    condition @(
        Common.Label : '{i18n>condition}',
        Common.Text : condition.name,
        Common.TextArrangement : #TextOnly,
        Common.ValueListWithFixedValues : true,
        Common.ValueList : {
            CollectionPath : 'ItemConditions',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : condition_code,
                    ValueListProperty : 'code'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name'
                }
            ]
        }
    );
    inspectionNotes @Common.Label : '{i18n>inspectionNotes}';
    inspectionDate @Common.Label : '{i18n>inspectionDate}';
    approved @Common.Label : '{i18n>approved}';
};

// Side Effects for RMAItems - Auto-calculate totals
annotate service.RMAItems with @(
    Common.SideEffects #ProductChanged : {
        SourceProperties : [product_ID],
        TargetProperties : ['unitPrice', 'totalPrice']
    },
    Common.SideEffects #QuantityChanged : {
        SourceProperties : [quantity],
        TargetProperties : ['totalPrice']
    },
    Common.SideEffects #PriceChanged : {
        SourceProperties : [unitPrice],
        TargetProperties : ['totalPrice']
    }
);

// Side Effects for RMAs - Recalculate total when items change
annotate service.RMAs with @(
    Common.SideEffects #ItemsChanged : {
        SourceEntities : [items],
        TargetProperties : ['totalAmount']
    }
);

////////////////////////////////////////////////////////////////////////////
//
// Customer - Contact Card
//
////////////////////////////////////////////////////////////////////////////

annotate service.Customers with @(
    Communication.Contact : {
        fn : companyName,
        n : {
            given : contactName
        },
        email : [{
            address : email,
            type : #work
        }],
        tel : [{
            uri : phone,
            type : #work
        }],
        adr : [{
            street : street,
            locality : city,
            code : postalCode,
            region : region,
            country : country
        }]
    }
);

annotate service.Customers with {
    ID @(
        UI.Hidden,
        Common.Label : '{i18n>ID}'
    );
    companyName @Common.Label : '{i18n>companyName}';
    contactName @Common.Label : '{i18n>contactName}';
    email @Common.Label : '{i18n>email}';
    phone @Common.Label : '{i18n>phone}';
};

////////////////////////////////////////////////////////////////////////////
//
// Products - Read-only Reference
//
////////////////////////////////////////////////////////////////////////////

annotate service.Products with {
    ID @(
        UI.Hidden,
        Common.Label : '{i18n>ID}'
    );
    productNumber @Common.Label : '{i18n>productNumber}';
    name @Common.Label : '{i18n>name}';
    price @(
        Common.Label : '{i18n>price}',
        Measures.ISOCurrency : currency
    );
    currency @(
        Common.Label : '{i18n>currency}',
        UI.Hidden : true
    );
};

////////////////////////////////////////////////////////////////////////////
//
// Code Lists - Status and Return Reasons
//
////////////////////////////////////////////////////////////////////////////

annotate service.RMAStatus with {
    code @Common.Label : '{i18n>statusCode}';
    name @Common.Label : '{i18n>statusName}';
};

annotate service.ItemConditions with {
    code @Common.Label : '{i18n>conditionCode}';
    name @Common.Label : '{i18n>conditionName}';
};

annotate service.ReturnReasons with {
    code @Common.Label : '{i18n>returnReasonCode}';
    name @Common.Label : '{i18n>returnReasonName}';
};

////////////////////////////////////////////////////////////////////////////
//
// Action Annotations - Show parameter dialogs with labels
// @Common.IsActionCritical forces Fiori to show confirmation/input dialog
// @Core.OperationAvailable controls button visibility based on virtual fields
//
////////////////////////////////////////////////////////////////////////////

annotate service.RMAs with actions {
    // Approve - only visible when status is REQUESTED
    approve @Core.OperationAvailable: canApprove;

    // Reject - only visible when status is REQUESTED
    rejectRMA @Common.IsActionCritical: true
              @Core.OperationAvailable: canReject
              (reason @Common.Label: 'Rejection Reason');

    // Mark Shipped - only visible when status is APPROVED
    markShipped @Common.IsActionCritical: true
                @Core.OperationAvailable: canMarkShipped
                (trackingNumber @Common.Label: 'Tracking Number');

    // Mark Received - only visible when status is SHIPPED
    markReceived @Core.OperationAvailable: canMarkReceived;

    // Complete Inspection - only visible when status is RECEIVED
    completeInspection @Core.OperationAvailable: canCompleteInspection;

    // Resolve RMA - only visible when status is INSPECTED
    resolveRMA @Common.IsActionCritical: true
               @Core.OperationAvailable: canResolve
               (resolutionType @Common.Label: 'Resolution Type',
                notes @Common.Label: 'Resolution Notes');
};
