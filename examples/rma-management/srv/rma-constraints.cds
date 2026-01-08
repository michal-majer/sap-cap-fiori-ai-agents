using { RMAService } from './rma-service';

/**
 * RMA Validation Constraints
 * Declarative validation using @assert annotation (December 2025 feature)
 *
 * This module defines business rules and validation constraints for RMA processing,
 * using CDS Expression Language (CXL) with case/when/then syntax.
 *
 * Features:
 * - Date validations (expectedReturnDate > rmaDate)
 * - Status-dependent field requirements (resolutionType required when RESOLVED)
 * - Referential integrity (customer, product must exist)
 * - Range constraints (quantity between 1-100)
 * - Code list validations (returnReason must exist)
 */

// RMA Constraints - Validations for Return Merchandise Authorization header entity
annotate RMAService.RMAs with {
  /**
   * expectedReturnDate must be after rmaDate
   * Error message: "Expected return date must be after RMA date"
   */
  expectedReturnDate @assert: (case
    when expectedReturnDate < rmaDate
      then 'Expected return date must be after RMA date'
  end);

  /**
   * resolutionType is required when status = RESOLVED
   * Ensures all resolved RMAs have a resolution type specified
   * Valid values: REFUND, REPLACEMENT, REPAIR, CREDIT
   */
  resolutionType @assert: (case
    when status.code = #RESOLVED and resolutionType is null
      then 'Resolution type required when resolving RMA'
  end);

  /**
   * customer must exist and be valid
   * Referential integrity constraint - customer must be present
   */
  customer @assert: (case
    when customer is null
      then 'Customer is required for RMA creation'
  end);
};

/**
 * RMA Items Constraints
 * Validations for RMA line items
 */
annotate RMAService.RMAItems with {
  /**
   * quantity must be between 1 and 100
   * Using @assert.range for numeric range validation
   */
  quantity @assert.range: [1, 100];

  /**
   * product must exist and be valid
   * Referential integrity constraint - product must be present
   */
  product @assert: (case
    when product is null
      then 'Product is required for RMA item'
  end);

  /**
   * returnReason must exist
   * Ensures return items have a documented reason for return
   * Reference to ReturnReasons code list
   */
  returnReason @assert: (case
    when returnReason is null
      then 'Return reason is required for RMA item'
  end);
};
