using { RMAService } from './rma-service';

// RMA Status Flow Definitions - Declarative state transitions using @flow.status
// Status Flow: REQUESTED → APPROVED → SHIPPED → RECEIVED → INSPECTED → RESOLVED
//                      ↓ REJECTED (terminal)
annotate RMAService.RMAs with @flow.status: status actions {
    /**
     * Approve an RMA request
     * Allowed from: REQUESTED
     * Transitions to: APPROVED
     */
    approve
        @from: [ #REQUESTED ]
        @to: #APPROVED;

    /**
     * Reject an RMA request
     * Allowed from: REQUESTED
     * Transitions to: REJECTED (terminal state)
     */
    rejectRMA
        @from: [ #REQUESTED ]
        @to: #REJECTED;

    /**
     * Mark RMA as shipped by customer
     * Allowed from: APPROVED
     * Transitions to: SHIPPED
     */
    markShipped
        @from: [ #APPROVED ]
        @to: #SHIPPED;

    /**
     * Mark RMA items as received at warehouse
     * Allowed from: SHIPPED
     * Transitions to: RECEIVED
     */
    markReceived
        @from: [ #SHIPPED ]
        @to: #RECEIVED;

    /**
     * Complete inspection of returned items
     * Allowed from: RECEIVED
     * Transitions to: INSPECTED
     */
    completeInspection
        @from: [ #RECEIVED ]
        @to: #INSPECTED;

    /**
     * Resolve the RMA with final resolution
     * Allowed from: INSPECTED
     * Transitions to: RESOLVED
     */
    resolveRMA
        @from: [ #INSPECTED ]
        @to: #RESOLVED;
};
