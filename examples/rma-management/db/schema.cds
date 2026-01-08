namespace rma.management;

using {
    cuid,
    managed,
    sap.common.CodeList
} from '@sap/cds/common';

/**
 * RMA Status Code List
 */
entity RMAStatus : CodeList {
    key code : String enum {
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

/**
 * Return Reasons - localized for multi-language support
 */
entity ReturnReasons : CodeList {
    key code                : String(20);
        requiresApproval    : Boolean default false;
        eligibleForRefund   : Boolean default true;
}

/**
 * Item Conditions - condition of returned items
 */
entity ItemConditions : CodeList {
    key code : String(20);
}

/**
 * Customers - Master data with contact information
 */
entity Customers : cuid, managed {
    customerNumber           : String(10) @(title: '{i18n>customerNumber}');
    companyName              : String(100) @title: '{i18n>companyName}';
    contactName              : String(100) @title: '{i18n>contactName}';
    email                    : String(100) @(
        title                : '{i18n>email}',
        Communication.IsEmailAddress
    );
    phone                    : String(30) @(
        title                : '{i18n>phone}',
        Communication.IsPhoneNumber
    );
    // Address fields
    street                   : String(100) @title: '{i18n>street}';
    city                     : String(100) @title: '{i18n>city}';
    postalCode               : String(10) @title: '{i18n>postalCode}';
    region                   : String(100) @title: '{i18n>region}';
    country                  : String(3) @title: '{i18n>country}';
    active                   : Boolean default true @title: '{i18n>active}';
    // Navigation
    rmas                     : Association to many RMAs
                                   on rmas.customer = $self;
}

/**
 * Products - Master data for returnable items
 */
entity Products : cuid, managed {
    productNumber : String(20) @(
        title : '{i18n>productNumber}',
        mandatory
    );
    name          : String(100) @title: '{i18n>name}';
    description   : String(500) @title: '{i18n>description}';
    category      : String(50) @title: '{i18n>category}';
    price         : Decimal(15, 2) @title: '{i18n>price}';
    currency      : String(3) default 'USD' @title: '{i18n>currency}';
    warrantyDays  : Integer @title: '{i18n>warrantyDays}';
    imageUrl      : String(500) @title: '{i18n>imageUrl}';
    active        : Boolean default true @title: '{i18n>active}';
    // Navigation
    rmaItems      : Association to many RMAItems
                        on rmaItems.product = $self;
}

/**
 * RMAs - Main entity for Return Merchandise Authorization
 */
entity RMAs : cuid, managed {
    rmaNumber         : String(20) @(
        title     : '{i18n>rmaNumber}',
        readonly,
        mandatory
    );
    rmaDate           : Date @(
        title     : '{i18n>rmaDate}',
        mandatory
    );
    customer          : Association to Customers @(
        title     : '{i18n>customer}',
        mandatory
    );
    status            : Association to RMAStatus default 'REQUESTED' @(
        title     : '{i18n>status}',
        mandatory
    );
    // Dates
    expectedReturnDate : Date @title: '{i18n>expectedReturnDate}';
    receivedDate       : Date @title: '{i18n>receivedDate}';
    resolutionDate     : Date @title: '{i18n>resolutionDate}';
    // Financial
    totalAmount        : Decimal(15, 2) @(
        title    : '{i18n>totalAmount}',
        readonly
    );
    currency           : String(3) default 'USD' @title: '{i18n>currency}';
    // Resolution
    resolutionType     : String(20) @title: '{i18n>resolutionType}'; // REFUND, REPLACEMENT, REPAIR, CREDIT
    resolutionNotes    : String(1000) @title: '{i18n>resolutionNotes}';
    // Approval
    approvedBy         : String(100) @title: '{i18n>approvedBy}';
    approvedDate       : Date @title: '{i18n>approvedDate}';
    rejectionReason    : String(500) @title: '{i18n>rejectionReason}';
    // Shipping
    trackingNumber     : String(50) @title: '{i18n>trackingNumber}';
    // Virtual fields for UI
    virtual criticality            : Integer @title: '{i18n>criticality}';
    // Action availability flags (computed based on status)
    virtual canApprove             : Boolean;
    virtual canReject              : Boolean;
    virtual canMarkShipped         : Boolean;
    virtual canMarkReceived        : Boolean;
    virtual canCompleteInspection  : Boolean;
    virtual canResolve             : Boolean;
    // Composition
    items              : Composition of many RMAItems
                             on items.rma = $self;
}

/**
 * RMA Items - Line items for each RMA
 */
entity RMAItems : cuid {
    rma             : Association to RMAs @(
        title       : '{i18n>rma}',
        mandatory
    );
    product         : Association to Products @(
        title       : '{i18n>product}',
        mandatory
    );
    quantity        : Integer @(
        title       : '{i18n>quantity}',
        mandatory
    );
    unitPrice       : Decimal(15, 2) @title: '{i18n>unitPrice}';
    totalPrice      : Decimal(15, 2) @title: '{i18n>totalPrice}';
    returnReason    : Association to ReturnReasons @title: '{i18n>returnReason}';
    condition       : Association to ItemConditions @title: '{i18n>condition}';
    inspectionNotes : String(1000) @title: '{i18n>inspectionNotes}';
    inspectionDate  : Date @title: '{i18n>inspectionDate}';
    approved        : Boolean default false @title: '{i18n>approved}';
}
