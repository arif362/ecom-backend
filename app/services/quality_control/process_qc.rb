module QualityControl
  class ProcessQc
    include Interactor

    delegate :order_id,
             :order_type,
             :variant_id,
             :received_quantity,
             :failed_quantity,
             :passed_quantity,
             :failed_reasons,
             :current_staff,
             :line_item,
             :warehouse_order,
             :warehouse_id,
             :remaining_quantity,
             to: :context

    def call
      context.warehouse_order = fetch_warehouse_order
      line_item = LineItem.find_by(itemable: context.warehouse_order, variant_id: variant_id)
      case warehouse_type
      when 'distribution', 'member', 'b2b'
        context.remaining_quantity = line_item.send_quantity - received_quantity
      when 'central'
        context.remaining_quantity = order_type == 'ReturnTransferOrder' ? line_item.send_quantity - received_quantity : line_item.quantity - received_quantity
      end
      create_failed_qc(FailedQc.qc_failed_types[:quality_failed], failed_quantity, line_item.id) if failed_quantity.positive?
      create_failed_qc(FailedQc.qc_failed_types[:quantity_failed], context.remaining_quantity, line_item.id) if context.remaining_quantity.positive?
      reconcilation_status = failed_quantity.positive? || context.remaining_quantity.positive? ? LineItem.reconcilation_statuses[:pending] : LineItem.reconcilation_statuses[:closed]
      context.line_item = update_line_item(fetch_line_item, reconcilation_status)
      unless context.warehouse_order.line_items.where(qc_status: false).present?
        context.warehouse_order.update!(changed_by: context.current_staff, order_status: context.warehouse_order.failed_qcs.where(is_settled: false).present? ? DhPurchaseOrder.order_statuses[:reconcilation_pending] : DhPurchaseOrder.order_statuses[:completed])
      end
    end

    def fetch_warehouse_order
      case warehouse_type
      when 'central'
        order_type.present? && order_type == 'ReturnTransferOrder' ? return_transfer_order : wh_purchase_order
      when 'distribution', 'member', 'b2b'
        dh_purchase_order
      end
    end

    def wh_purchase_order
      WhPurchaseOrder.find(order_id)
    end

    def dh_purchase_order
      DhPurchaseOrder.find(order_id)
    end

    def return_transfer_order
      ReturnTransferOrder.find(order_id)
    end

    def fetch_line_item
      context.warehouse_order.line_items.where(variant_id: variant_id).first
    end

    def create_failed_qc(type, qty, line_item_id)
      FailedQc.create!(failed_qc_attributes(type, qty, line_item_id))
      update_warehouse_variants_failed_qc(type, qty)
    end

    def update_line_item(line_item, reconcilation_status)
      updated_line_item = line_item.update!(attributes_for_update(reconcilation_status))
      update_warehouse_variants_passed_qc(passed_quantity)
      line_item if updated_line_item
    end

    def failed_qc_attributes(failed_type, qty, line_item_id)
      {
        variant_id: variant_id,
        quantity: qty,
        failed_reasons: process_failed_reasons,
        failable: context.warehouse_order,
        warehouse_id: context.warehouse_id,
        qc_failed_type: failed_type,
        line_item_id: line_item_id,
      }
    end

    def attributes_for_update(reconcilation_status)
      {
        received_quantity: received_quantity,
        qc_passed: passed_quantity.to_i,
        qc_failed: failed_quantity.to_i,
        remaining_quantity: remaining_quantity.to_i,
        qc_status: true,
        reconcilation_status: reconcilation_status,
      }
    end

    def process_failed_reasons
      {
        failed_reasons: failed_reasons,
      }
    end

    def warehouse_type
      Warehouse.find(context.warehouse_id).warehouse_type
    end

    def warehouse_variant
      WarehouseVariant.find_by(warehouse_id: warehouse_id, variant_id: variant_id)
    end

    def stock_changeable_value
      {
        stock_changeable_name: order_type.constantize.find_by(id: order_id),
        stock_transaction_type_prefix: if order_type == 'WhPurchaseOrder'
                                        'po'
                                       elsif order_type == 'DhPurchaseOrder'
                                         'sto'
                                       elsif order_type == 'ReturnTransferOrder'
                                        'rto'
                                       else
                                         ''
                                       end
      }
    end
  
    def update_warehouse_variants_failed_qc(type, qty)
      wv = warehouse_variant
      scv = stock_changeable_value
      stock_changeable = scv[:stock_changeable_name]
      transaction_prefix = scv[:stock_transaction_type_prefix]
      if type == FailedQc.qc_failed_types[:quantity_failed]
        wv.update!(qty_qc_failed_quantity: wv.qty_qc_failed_quantity + qty, qc_pending_quantity:  wv.qc_pending_quantity -  qty)
        wv.save_stock_change(transaction_prefix.concat('_qty_qc_failed'), qty, stock_changeable, 'qc_pending_quantity_change' , 'qty_qc_failed_quantity_change')
      else
        wv.update!(qly_qc_failed_quantity: wv.qly_qc_failed_quantity + qty, qc_pending_quantity:  wv.qc_pending_quantity -  qty)
        wv.save_stock_change(transaction_prefix.concat('_qly_qc_failed'), qty, stock_changeable, 'qc_pending_quantity_change' , 'qly_qc_failed_quantity_change')
      end
    end

    def update_warehouse_variants_passed_qc(passed_quantity)
      wv = warehouse_variant
      scv = stock_changeable_value
      stock_changeable = scv[:stock_changeable_name]
      transaction_prefix = scv[:stock_transaction_type_prefix]
      wv.update!(qc_pending_quantity:  wv.qc_pending_quantity - passed_quantity.to_i, location_pending_quantity: wv.location_pending_quantity + passed_quantity.to_i)
      wv.save_stock_change(transaction_prefix.concat('_location_pending'), passed_quantity, stock_changeable, 'qc_pending_quantity_change' , 'location_pending_quantity_change')
    end
  end
end
