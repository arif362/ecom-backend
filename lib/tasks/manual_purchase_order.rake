require 'csv'
namespace :manual_purchase_order do
  task wh_create: :environment do |t, args|
    index = 0
    csv_file = Rails.root.join('tmp/csv/supplier_purchase_orders.csv')
    po_list = Hash.new
    CSV.foreach(csv_file, headers: true) do |row|
      index += 1

      if po_list.key? row.fetch('dummy_po_no').to_i
        po = po_list[row.fetch('dummy_po_no').to_i]
      else
        supplier = Supplier.find(row.fetch('supplier_id').to_i)
        po = WhPurchaseOrder.create!(
          supplier: supplier,
          quantity: 0,
          total_price: 0,
          order_status: WhPurchaseOrder.order_statuses[:completed]
        )
        po_list[row.fetch('dummy_po_no').to_i] = po
        puts "#{index}:New purchase order created with ID #{po.id}"
      end
      puts "#{index}:New purchase order created with ID #{po.id}"
      warehouse = Warehouse.find(row.fetch('warehouse_id').to_i)
      variant = Variant.find(row.fetch('variant_id').to_i)
      price = variant.suppliers_variants.find_by(supplier: po.supplier)&.supplier_price
      create_new_line_item(row, po, variant, price, warehouse)
      puts "#{index}:line_item created for po #{po.id} with variant ID #{variant.id}"
    end
  rescue => ex
    puts "Error in row #{index}. #{ex.full_message}"
  end

  task dh_create: :environment do |t, args|
    index = 0
    csv_file = Rails.root.join('tmp/csv/distribution_purchase_orders.csv')
    po_list = Hash.new
    CSV.foreach(csv_file, headers: true) do |row|
      index += 1
      warehouse = Warehouse.find(row.fetch('warehouse_id').to_i)

      if po_list.key? row.fetch('dummy_po_no').to_i
        po = po_list[row.fetch('dummy_po_no').to_i]
      else
        po = DhPurchaseOrder.create!(
          warehouse: warehouse,
          quantity: 0,
          total_price: 0,
          order_status: WhPurchaseOrder.order_statuses[:completed]
        )
        po_list[row.fetch('dummy_po_no').to_i] = po
        puts "#{index}:New purchase order created with ID #{po.id}"
      end

      variant = Variant.find(row.fetch('variant_id').to_i)
      price = variant.effective_mrp
      create_new_line_item(row, po, variant, price, warehouse)
      puts "#{index}:line_item created for po #{po.id} with variant ID #{variant.id}"
    end
  rescue => ex
    puts "Error in row #{index}. #{ex.full_message}"
  end

  def create_new_line_item(row, po, variant, price, warehouse)
    qc_failed = row.fetch('failed_quantity').to_i
    if qc_failed == 0
      line_item_status = LineItem.reconcilation_statuses[:settled]
    elsif qc_failed.positive?
      line_item_status = LineItem.reconcilation_statuses[:pending]
    end
    location = Location.find(row.fetch('location_id').to_i)
    qc_passed_qty = row.fetch('quantity').to_i - qc_failed
    line_item = po.line_items.create!(
      variant: variant,
      quantity: row.fetch('quantity').to_i,
      price: price,
      received_quantity: row.fetch('quantity').to_i,
      qc_passed: qc_passed_qty,
      qc_failed: qc_failed,
      qc_status: true,
      reconcilation_status: line_item_status,
      location: location
    )

    # Update warehouse and location available qty with qc_passed items
    warehouse_variant = warehouse.warehouse_variants.find_or_create_by(variant_id: variant.id)
    warehouse_variant.update!(available_quantity: warehouse_variant.available_quantity + qc_passed_qty)
    warehouse_variants_location = warehouse_variant.warehouse_variants_locations.find_or_create_by(location_id: location.id)
    warehouse_variants_location.update!(quantity: warehouse_variants_location.quantity + qc_passed_qty)
    # End of update

    po.order_status = WhPurchaseOrder.order_statuses[:reconcilation_pending] if qc_failed.positive?
    po.quantity = po.quantity + line_item.quantity
    po.total_price = po.total_price + (line_item.price.to_d * line_item.quantity)
    po.save

    if qc_failed.positive?
      po.failed_qcs.create!(
        warehouse: warehouse,
        variant: variant,
        quantity: qc_failed,
        qc_failed_type: FailedQc.qc_failed_types[:quality_failed],
        failed_reasons: []
      )
    end
  end
end
