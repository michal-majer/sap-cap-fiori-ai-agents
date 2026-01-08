using rma.management from '../db/schema';

/**
 * RMA Service - Main service for RMA processing
 * Provides draft-enabled editing and business actions for RMA workflow
 */
@requires: 'authenticated-user'
service RMAService {

    /**
     * RMAs - Main entity with draft support for complex editing
     * Includes custom actions for state transitions and business operations
     */
    @odata.draft.enabled
    entity RMAs as projection on management.RMAs actions {
        /**
         * Approve an RMA request
         * Transitions status from REQUESTED to APPROVED
         */
        action approve();

        /**
         * Reject an RMA request with a reason
         * Transitions status from REQUESTED to REJECTED
         * @param reason - Explanation for rejection
         */
        action rejectRMA(reason : String(500));

        /**
         * Mark RMA as shipped by customer
         * Transitions status from APPROVED to SHIPPED
         * @param trackingNumber - Shipping tracking number
         */
        action markShipped(trackingNumber : String(50));

        /**
         * Mark RMA items as received at warehouse
         * Transitions status from SHIPPED to RECEIVED
         */
        action markReceived();

        /**
         * Complete inspection of returned items
         * Transitions status from RECEIVED to INSPECTED
         */
        action completeInspection();

        /**
         * Resolve the RMA with final resolution
         * Transitions status from INSPECTED to RESOLVED
         * @param resolutionType - Type of resolution (REFUND, REPLACEMENT, REPAIR, CREDIT)
         * @param notes - Resolution notes
         */
        action resolveRMA(
            resolutionType : String(20),
            notes          : String(1000)
        );
    };

    /**
     * RMA Items - Line items for returns
     * Editable through RMAs composition
     */
    entity RMAItems   as projection on management.RMAItems;

    /**
     * Products - Read-only for selection in RMA items
     */
    @readonly
    entity Products   as projection on management.Products;

    /**
     * Customers - Read-only for selection in RMAs
     */
    @readonly
    entity Customers  as projection on management.Customers;

    /**
     * Return Reasons - Read-only code list
     */
    @readonly
    entity ReturnReasons as projection on management.ReturnReasons;

    /**
     * Item Conditions - Read-only code list
     */
    @readonly
    entity ItemConditions as projection on management.ItemConditions;

    /**
     * RMA Status - Read-only code list
     */
    @readonly
    entity RMAStatus  as projection on management.RMAStatus;
}

/**
 * Admin Service - Administrative functions
 * Requires 'admin' role for access
 * Provides full CRUD for master data and reporting access to RMAs
 */
@requires: 'admin'
service AdminService {

    /**
     * Products - Full CRUD for product master data
     */
    entity Products      as projection on management.Products;

    /**
     * Customers - Full CRUD for customer master data
     */
    entity Customers     as projection on management.Customers;

    /**
     * Return Reasons - Full CRUD for return reason codes
     */
    entity ReturnReasons as projection on management.ReturnReasons;

    /**
     * RMAs - Read-only for reporting and analytics
     */
    @readonly
    entity RMAs          as projection on management.RMAs;

    /**
     * RMA Items - Read-only for reporting
     */
    @readonly
    entity RMAItems      as projection on management.RMAItems;

    /**
     * RMA Status - Read-only code list
     */
    @readonly
    entity RMAStatus     as projection on management.RMAStatus;
}
