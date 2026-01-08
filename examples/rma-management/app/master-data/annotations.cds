using AdminService as service from '../../srv/rma-service';

////////////////////////////////////////////////////////////////////////////
//
// Master Data Management App - UI Annotations
// Administrative application for managing Products and Customers
//
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
//
// Products - Master Data
//
////////////////////////////////////////////////////////////////////////////

annotate service.Products with @(
    UI.SelectionFields : [
        productNumber,
        name,
        category,
        active
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : productNumber,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : name,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : category,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : price,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : warrantyDays,
            ![@UI.Importance] : #Medium
        },
        {
            $Type : 'UI.DataField',
            Value : active,
            ![@UI.Importance] : #Medium
        }
    ],
    UI.HeaderInfo : {
        TypeName : '{i18n>product}',
        TypeNamePlural : '{i18n>products}',
        Title : { Value : name },
        Description : { Value : productNumber },
        ImageUrl : imageUrl
    },
    UI.HeaderFacets : [
        {
            $Type : 'UI.ReferenceFacet',
            Target : '@UI.DataPoint#Price',
            Label : '{i18n>price}'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target : '@UI.DataPoint#Active',
            Label : '{i18n>status}'
        }
    ],
    UI.DataPoint #Price : {
        Value : price,
        Title : '{i18n>price}'
    },
    UI.DataPoint #Active : {
        Value : active,
        Title : '{i18n>active}'
    },
    UI.Facets : [
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>productDetails}',
            ID : 'ProductDetails',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#ProductDetails',
                    Label : '{i18n>details}'
                }
            ]
        },
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>pricingInformation}',
            ID : 'PricingInfo',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#PricingInfo',
                    Label : '{i18n>pricing}'
                }
            ]
        },
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>warrantyInformation}',
            ID : 'WarrantyInfo',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#WarrantyInfo',
                    Label : '{i18n>warranty}'
                }
            ]
        },
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>systemInformation}',
            ID : 'SystemInfo',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#SystemInfo',
                    Label : '{i18n>system}'
                }
            ]
        }
    ],
    UI.FieldGroup #ProductDetails : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : productNumber
            },
            {
                $Type : 'UI.DataField',
                Value : name
            },
            {
                $Type : 'UI.DataField',
                Value : description,
                ![@UI.MultiLineText] : true
            },
            {
                $Type : 'UI.DataField',
                Value : category
            },
            {
                $Type : 'UI.DataField',
                Value : imageUrl
            },
            {
                $Type : 'UI.DataField',
                Value : active
            }
        ]
    },
    UI.FieldGroup #PricingInfo : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : price
            },
            {
                $Type : 'UI.DataField',
                Value : currency
            }
        ]
    },
    UI.FieldGroup #WarrantyInfo : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : warrantyDays
            }
        ]
    },
    UI.FieldGroup #SystemInfo : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : createdAt
            },
            {
                $Type : 'UI.DataField',
                Value : createdBy
            },
            {
                $Type : 'UI.DataField',
                Value : modifiedAt
            },
            {
                $Type : 'UI.DataField',
                Value : modifiedBy
            }
        ]
    }
);

// Field-level annotations for Products
annotate service.Products with {
    ID @(
        UI.Hidden,
        Common.Label : '{i18n>ID}'
    );
    productNumber @(
        Common.Label : '{i18n>productNumber}',
        Common.FieldControl : #Mandatory
    );
    name @(
        Common.Label : '{i18n>name}',
        Common.FieldControl : #Mandatory
    );
    description @Common.Label : '{i18n>description}';
    category @(
        Common.Label : '{i18n>category}',
        Common.ValueListWithFixedValues : false
    );
    price @(
        Common.Label : '{i18n>price}',
        Measures.ISOCurrency : currency
    );
    currency @(
        Common.Label : '{i18n>currency}',
        Common.ValueListWithFixedValues : true
    );
    warrantyDays @(
        Common.Label : '{i18n>warrantyDays}',
        Measures.Unit : 'Days'
    );
    imageUrl @Common.Label : '{i18n>imageUrl}';
    active @Common.Label : '{i18n>active}';
    createdAt @(
        Common.Label : '{i18n>createdAt}',
        UI.HiddenFilter : true
    );
    createdBy @(
        Common.Label : '{i18n>createdBy}',
        UI.HiddenFilter : true
    );
    modifiedAt @(
        Common.Label : '{i18n>modifiedAt}',
        UI.HiddenFilter : true
    );
    modifiedBy @(
        Common.Label : '{i18n>modifiedBy}',
        UI.HiddenFilter : true
    );
};

////////////////////////////////////////////////////////////////////////////
//
// Customers - Master Data
//
////////////////////////////////////////////////////////////////////////////

annotate service.Customers with @(
    UI.SelectionFields : [
        customerNumber,
        companyName,
        city,
        country,
        active
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : customerNumber,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : companyName,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : contactName,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : email,
            ![@UI.Importance] : #Medium
        },
        {
            $Type : 'UI.DataField',
            Value : phone,
            ![@UI.Importance] : #Medium
        },
        {
            $Type : 'UI.DataField',
            Value : city,
            ![@UI.Importance] : #Medium
        },
        {
            $Type : 'UI.DataField',
            Value : country,
            ![@UI.Importance] : #Medium
        },
        {
            $Type : 'UI.DataField',
            Value : active,
            ![@UI.Importance] : #Medium
        }
    ],
    UI.HeaderInfo : {
        TypeName : '{i18n>customer}',
        TypeNamePlural : '{i18n>customers}',
        Title : { Value : companyName },
        Description : { Value : customerNumber }
    },
    UI.HeaderFacets : [
        {
            $Type : 'UI.ReferenceFacet',
            Target : '@UI.FieldGroup#ContactCard',
            Label : '{i18n>contact}'
        }
    ],
    UI.FieldGroup #ContactCard : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : email
            },
            {
                $Type : 'UI.DataField',
                Value : phone
            }
        ]
    },
    UI.Facets : [
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>companyInformation}',
            ID : 'CompanyInfo',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#CompanyInfo',
                    Label : '{i18n>company}'
                }
            ]
        },
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>contactDetails}',
            ID : 'ContactDetails',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#ContactDetails',
                    Label : '{i18n>contact}'
                }
            ]
        },
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>addressInformation}',
            ID : 'AddressInfo',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#AddressInfo',
                    Label : '{i18n>address}'
                }
            ]
        },
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>systemInformation}',
            ID : 'SystemInfo',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#SystemInfo',
                    Label : '{i18n>system}'
                }
            ]
        }
    ],
    UI.FieldGroup #CompanyInfo : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : customerNumber
            },
            {
                $Type : 'UI.DataField',
                Value : companyName
            },
            {
                $Type : 'UI.DataField',
                Value : active
            }
        ]
    },
    UI.FieldGroup #ContactDetails : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : contactName
            },
            {
                $Type : 'UI.DataField',
                Value : email
            },
            {
                $Type : 'UI.DataField',
                Value : phone
            }
        ]
    },
    UI.FieldGroup #AddressInfo : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : street
            },
            {
                $Type : 'UI.DataField',
                Value : city
            },
            {
                $Type : 'UI.DataField',
                Value : postalCode
            },
            {
                $Type : 'UI.DataField',
                Value : region
            },
            {
                $Type : 'UI.DataField',
                Value : country
            }
        ]
    },
    UI.FieldGroup #SystemInfo : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : createdAt
            },
            {
                $Type : 'UI.DataField',
                Value : createdBy
            },
            {
                $Type : 'UI.DataField',
                Value : modifiedAt
            },
            {
                $Type : 'UI.DataField',
                Value : modifiedBy
            }
        ]
    },
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

// Field-level annotations for Customers
annotate service.Customers with {
    ID @(
        UI.Hidden,
        Common.Label : '{i18n>ID}'
    );
    customerNumber @(
        Common.Label : '{i18n>customerNumber}',
        Common.FieldControl : #Mandatory
    );
    companyName @(
        Common.Label : '{i18n>companyName}',
        Common.FieldControl : #Mandatory
    );
    contactName @Common.Label : '{i18n>contactName}';
    email @Common.Label : '{i18n>email}';
    phone @Common.Label : '{i18n>phone}';
    street @Common.Label : '{i18n>street}';
    city @Common.Label : '{i18n>city}';
    postalCode @Common.Label : '{i18n>postalCode}';
    region @Common.Label : '{i18n>region}';
    country @(
        Common.Label : '{i18n>country}',
        Common.ValueListWithFixedValues : false
    );
    active @Common.Label : '{i18n>active}';
    createdAt @(
        Common.Label : '{i18n>createdAt}',
        UI.HiddenFilter : true
    );
    createdBy @(
        Common.Label : '{i18n>createdBy}',
        UI.HiddenFilter : true
    );
    modifiedAt @(
        Common.Label : '{i18n>modifiedAt}',
        UI.HiddenFilter : true
    );
    modifiedBy @(
        Common.Label : '{i18n>modifiedBy}',
        UI.HiddenFilter : true
    );
};

////////////////////////////////////////////////////////////////////////////
//
// Return Reasons - Code List Management
//
////////////////////////////////////////////////////////////////////////////

annotate service.ReturnReasons with @(
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : code,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : name,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : requiresApproval,
            ![@UI.Importance] : #Medium
        },
        {
            $Type : 'UI.DataField',
            Value : eligibleForRefund,
            ![@UI.Importance] : #Medium
        }
    ],
    UI.HeaderInfo : {
        TypeName : '{i18n>returnReason}',
        TypeNamePlural : '{i18n>returnReasons}',
        Title : { Value : name },
        Description : { Value : code }
    },
    UI.Facets : [
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>details}',
            ID : 'Details',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#Details',
                    Label : '{i18n>reasonDetails}'
                }
            ]
        }
    ],
    UI.FieldGroup #Details : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : code
            },
            {
                $Type : 'UI.DataField',
                Value : name
            },
            {
                $Type : 'UI.DataField',
                Value : requiresApproval
            },
            {
                $Type : 'UI.DataField',
                Value : eligibleForRefund
            }
        ]
    }
);

annotate service.ReturnReasons with {
    code @(
        Common.Label : '{i18n>returnReasonCode}',
        Common.FieldControl : #Mandatory
    );
    name @(
        Common.Label : '{i18n>returnReasonName}',
        Common.FieldControl : #Mandatory
    );
    requiresApproval @Common.Label : '{i18n>requiresApproval}';
    eligibleForRefund @Common.Label : '{i18n>eligibleForRefund}';
};

////////////////////////////////////////////////////////////////////////////
//
// RMAs - Read-only for Reporting (minimal annotations)
//
////////////////////////////////////////////////////////////////////////////

annotate service.RMAs with @(
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
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : totalAmount,
            ![@UI.Importance] : #High
        },
        {
            $Type : 'UI.DataField',
            Value : rmaDate,
            ![@UI.Importance] : #Medium
        },
        {
            $Type : 'UI.DataField',
            Value : resolutionType,
            ![@UI.Importance] : #Medium
        }
    ]
);

annotate service.RMAs with {
    ID @(
        UI.Hidden,
        Common.Label : '{i18n>ID}'
    );
    rmaNumber @Common.Label : '{i18n>rmaNumber}';
    customer @(
        Common.Label : '{i18n>customer}',
        Common.Text : customer.companyName,
        Common.TextArrangement : #TextOnly
    );
    status @(
        Common.Label : '{i18n>status}',
        Common.Text : status.name,
        Common.TextArrangement : #TextOnly
    );
    totalAmount @(
        Common.Label : '{i18n>totalAmount}',
        Measures.ISOCurrency : currency
    );
    currency @UI.Hidden : true;
};

////////////////////////////////////////////////////////////////////////////
//
// RMA Status - Read-only Code List
//
////////////////////////////////////////////////////////////////////////////

annotate service.RMAStatus with {
    code @Common.Label : '{i18n>statusCode}';
    name @Common.Label : '{i18n>statusName}';
};
