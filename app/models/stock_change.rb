class StockChange < ApplicationRecord
  # The existing stock_changes doesn't have any warehouse or variant.
  # So I made warehouse and variant optional
  belongs_to :warehouse, optional: true
  belongs_to :variant, optional: true
  belongs_to :warehouse_variant
  belongs_to :stock_changeable, polymorphic: true

  enum stock_transaction_type:
         {
           initial_stock: 0,
           location_assign_after_inbound_qc: 1,
           sto_pack: 2,
           sto_in_transit: 3,
           sto_receive_to_dh: 4,
           received_for_failed_qc_sku: 5,
           order_placed: 6,
           cancel_from_order_placed: 7,
           unpack_a_cancelled_customer_order: 8,
           customer_order_pack: 9,
           customer_order_in_transit: 10,
           customer_order_in_partner: 11,
           customer_order_completed: 12,
           customer_order_packed_returned: 13,
           location_assign_after_return_qc: 14,
           dh_received_packed_customer_order: 15,
           sku_block: 16,
           sku_unblock: 17,
           garbage_blocked_sku: 18,
           bundle_pack: 19,
           bundle_unpack: 20,
           rto_pack: 21,
           rto_in_transit: 22,
           rto_received_to_cwh: 23,
           location_assign_after_rto_qc: 24,
           po_qc_pending: 25,
           po_qty_qc_failed: 26,
           po_qly_qc_failed: 27,
           po_location_pending: 28,
           sto_qc_pending: 29,
           sto_qty_qc_failed: 30,
           sto_qly_qc_failed: 31,
           sto_location_pending: 32,
           rto_qc_pending: 33,
           rto_qty_qc_failed: 34,
           rto_qly_qc_failed: 35,
           rto_location_pending: 36,
           return_order_in_partner: 37,
           return_order_in_transit: 38,
           return_order_in_dh: 39,
           return_order_in_transit_to_fc: 40,
           return_order_qc_pending: 41,
           return_order_qc_failed: 42,
           return_order_location_pending: 44,
           ready_to_ship_from_fc: 45,
           in_transit_to_dh: 46,
           ready_to_ship: 47,
           cancelled_at_in_transit_to_dh: 48,
           cancelled_at_dh: 49,
           cancelled_in_transit: 50,
           cancelled_at_in_transit_to_fc: 51,
           cancelled_in_transit_received: 52,
          }
  validates_uniqueness_of :warehouse_variant_id,
                          scope: %i(stock_changeable_id stock_changeable_type stock_transaction_type),
                          conditions: -> { where.not(stock_transaction_type: %i(customer_order_in_transit dh_received_packed_customer_order sku_unblock received_for_failed_qc_sku garbage_blocked_sku bundle_pack bundle_unpack)) }
end
