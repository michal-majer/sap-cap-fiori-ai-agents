const cds = require('@sap/cds');

/**
 * RMA Service Implementation
 * Implements business logic for RMA processing workflow
 */
module.exports = class RMAService extends cds.ApplicationService {
    async init() {
        const { RMAs, RMAItems } = this.entities;

        // ========================================
        // 1. AUTO-GENERATE RMA NUMBERS
        // ========================================
        this.before('CREATE', 'RMAs', async (req) => {
            const rma = req.data;

            // Generate RMA number if not provided
            if (!rma.rmaNumber) {
                rma.rmaNumber = await this.generateRMANumber();
            }

            // Set RMA date to today if not provided
            if (!rma.rmaDate) {
                rma.rmaDate = new Date().toISOString().split('T')[0];
            }
        });

        // ========================================
        // 2. CALCULATE TOTAL AMOUNT
        // ========================================

        // Calculate item total price when item is created or updated
        // This handler works for both active entities and drafts
        const calculateItemTotals = async (req, next) => {
            const item = req.data;
            const itemID = req.params?.[0]?.ID || item.ID;

            // For UPDATE, fetch existing values to merge with changes
            let existingItem = null;
            if (itemID) {
                // Try draft first (more likely during editing), then active
                existingItem = await SELECT.one.from('RMAService.RMAItems.drafts').where({ ID: itemID });
                if (!existingItem) {
                    existingItem = await SELECT.one.from(RMAItems).where({ ID: itemID });
                }
            }

            // Merge existing values with new data
            const quantity = item.quantity ?? existingItem?.quantity;
            let unitPrice = item.unitPrice ?? existingItem?.unitPrice;

            // If product is selected (new or changed), get price from product
            const productID = item.product_ID ?? existingItem?.product_ID;
            if (productID && (item.product_ID || !unitPrice)) {
                const product = await SELECT.one.from('rma.management.Products')
                    .where({ ID: productID })
                    .columns('price');

                if (product) {
                    unitPrice = product.price;
                    req.data.unitPrice = unitPrice;
                }
            }

            // Calculate totalPrice from quantity * unitPrice
            if (quantity && unitPrice) {
                req.data.totalPrice = quantity * unitPrice;
            }

            // Call the default handler
            return next();
        };

        // Register 'on' handlers to intercept and calculate before save
        this.on(['CREATE', 'UPDATE'], 'RMAItems', calculateItemTotals);
        this.on(['CREATE', 'UPDATE'], 'RMAItems.drafts', calculateItemTotals);

        // Recalculate RMA total after items are modified
        const updateRMATotal = async (result, req) => {
            const rmaID = req.data.rma_ID || (result && result.rma_ID);

            if (rmaID) {
                await this.updateRMATotalAmount(rmaID);
            }
        };

        this.after(['CREATE', 'UPDATE', 'DELETE'], 'RMAItems', updateRMATotal);
        this.after(['CREATE', 'UPDATE', 'DELETE'], 'RMAItems.drafts', updateRMATotal);

        // Set virtual fields for both active and draft entities
        // This handler computes criticality and action availability based on status
        const setVirtualFields = (rmas) => {
            if (!rmas) return;
            const rmaArray = Array.isArray(rmas) ? rmas : [rmas];
            for (const rma of rmaArray) {
                if (rma) {
                    const status = rma.status_code;
                    const isActive = rma.IsActiveEntity !== false; // true for active, undefined for non-draft
                    // Set criticality for status coloring
                    rma.criticality = this.calculateCriticality(status);
                    // Set action availability flags based on current status
                    // Actions only available on active entities (not drafts)
                    rma.canApprove = isActive && status === 'REQUESTED';
                    rma.canReject = isActive && status === 'REQUESTED';
                    rma.canMarkShipped = isActive && status === 'APPROVED';
                    rma.canMarkReceived = isActive && status === 'SHIPPED';
                    rma.canCompleteInspection = isActive && status === 'RECEIVED';
                    rma.canResolve = isActive && status === 'INSPECTED';
                }
            }
        };

        // Handle both active entities and drafts
        this.after('READ', 'RMAs', setVirtualFields);
        this.after('READ', 'RMAs.drafts', setVirtualFields);

        // ========================================
        // 4. ACTION HANDLERS
        // IMPORTANT: Use 'before' handlers to set business fields BEFORE @flow.status runs
        // @flow.status generic handler runs AFTER and handles the status transition
        // ========================================

        /**
         * Approve an RMA request
         * @flow.status handles: REQUESTED → APPROVED
         * Handler sets: approvedBy, approvedDate
         */
        this.before('approve', 'RMAs', async (req) => {
            const { ID } = req.params[0];
            const user = req.user.id || 'system';
            const today = new Date().toISOString().split('T')[0];

            await UPDATE(RMAs, ID).with({
                approvedBy: user,
                approvedDate: today
            });
        });

        /**
         * Reject an RMA request with a reason
         * @flow.status handles: REQUESTED → REJECTED
         * Handler sets: rejectionReason
         */
        this.before('rejectRMA', 'RMAs', async (req) => {
            const { ID } = req.params[0];
            const { reason } = req.data;

            if (!reason) {
                return req.reject(400, 'Rejection reason is required');
            }

            await UPDATE(RMAs, ID).with({
                rejectionReason: reason
            });
        });

        /**
         * Mark RMA as shipped by customer
         * @flow.status handles: APPROVED → SHIPPED
         * Handler sets: trackingNumber
         */
        this.before('markShipped', 'RMAs', async (req) => {
            const { ID } = req.params[0];
            const { trackingNumber } = req.data;

            if (!trackingNumber) {
                return req.reject(400, 'Tracking number is required');
            }

            await UPDATE(RMAs, ID).with({
                trackingNumber: trackingNumber
            });
        });

        /**
         * Mark RMA items as received at warehouse
         * @flow.status handles: SHIPPED → RECEIVED
         * Handler sets: receivedDate
         */
        this.before('markReceived', 'RMAs', async (req) => {
            const { ID } = req.params[0];
            const today = new Date().toISOString().split('T')[0];

            await UPDATE(RMAs, ID).with({
                receivedDate: today
            });
        });

        /**
         * Complete inspection of returned items
         * @flow.status handles: RECEIVED → INSPECTED
         * Handler sets: inspectionDate on all items
         */
        this.before('completeInspection', 'RMAs', async (req) => {
            const { ID } = req.params[0];
            const today = new Date().toISOString().split('T')[0];

            // Set inspection date on all items
            await UPDATE('rma.management.RMAItems')
                .where({ rma_ID: ID })
                .with({ inspectionDate: today });
        });

        /**
         * Resolve the RMA with final resolution
         * @flow.status handles: INSPECTED → RESOLVED
         * Handler sets: resolutionType, resolutionNotes, resolutionDate
         */
        this.before('resolveRMA', 'RMAs', async (req) => {
            const { ID } = req.params[0];
            const { resolutionType, notes } = req.data;
            const today = new Date().toISOString().split('T')[0];

            if (!resolutionType) {
                return req.reject(400, 'Resolution type is required (REFUND, REPLACEMENT, REPAIR, CREDIT)');
            }

            // Validate resolution type
            const validTypes = ['REFUND', 'REPLACEMENT', 'REPAIR', 'CREDIT'];
            if (!validTypes.includes(resolutionType)) {
                return req.reject(400, `Invalid resolution type. Must be one of: ${validTypes.join(', ')}`);
            }

            await UPDATE(RMAs, ID).with({
                resolutionType: resolutionType,
                resolutionNotes: notes || null,
                resolutionDate: today
            });
        });

        return super.init();
    }

    // ========================================
    // HELPER METHODS
    // ========================================

    /**
     * Generate RMA number in format: RMA-YYYYMMDD-XXXXX
     * @returns {String} Generated RMA number
     */
    async generateRMANumber() {
        // Get current date in YYYYMMDD format
        const today = new Date();
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');
        const dateStr = `${year}${month}${day}`;

        // Generate random 5-digit sequence
        const sequence = String(Math.floor(Math.random() * 100000)).padStart(5, '0');

        return `RMA-${dateStr}-${sequence}`;
    }

    /**
     * Calculate total amount for an RMA by summing all item totalPrices
     * Works with both active entities and drafts
     * @param {String} rmaID - The RMA ID
     */
    async updateRMATotalAmount(rmaID) {
        // Try to get items from active entity first
        let items = await SELECT.from('rma.management.RMAItems')
            .where({ rma_ID: rmaID })
            .columns('totalPrice');

        // If no items found, try draft items
        if (!items || items.length === 0) {
            items = await SELECT.from('RMAService.RMAItems.drafts')
                .where({ rma_ID: rmaID })
                .columns('totalPrice');
        }

        // Calculate sum
        const total = items.reduce((sum, item) => {
            return sum + (item.totalPrice || 0);
        }, 0);

        // Try to update active entity first
        const activeResult = await UPDATE('rma.management.RMAs', rmaID).with({
            totalAmount: total
        });

        // If no rows updated, try draft
        if (activeResult === 0) {
            await UPDATE('RMAService.RMAs.drafts', rmaID).with({
                totalAmount: total
            });
        }
    }

    /**
     * Calculate criticality based on status
     * @param {String} status - The RMA status code
     * @returns {Integer} Criticality value for UI coloring
     *
     * Criticality values:
     * - 1 (red): REJECTED
     * - 2 (yellow): REQUESTED
     * - 0 (neutral): APPROVED, SHIPPED, RECEIVED, INSPECTED
     * - 3 (green): RESOLVED, CLOSED
     */
    calculateCriticality(status) {
        if (!status) return 0;

        switch (status) {
            case 'REJECTED':
                return 1; // Red
            case 'REQUESTED':
                return 2; // Yellow
            case 'RESOLVED':
            case 'CLOSED':
                return 3; // Green
            case 'APPROVED':
            case 'SHIPPED':
            case 'RECEIVED':
            case 'INSPECTED':
            default:
                return 0; // Neutral
        }
    }
};
