require 'csv'
namespace :purchase_order do
  task create_for_wh: :environment do |t, args|
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
        )
        po_list[row.fetch('dummy_po_no').to_i] = po
        puts "#{index}:New purchase order created with ID #{po.id}"
      end

      variant = Variant.find(row.fetch('variant_id').to_i)
      price = variant.suppliers_variants.find_by(supplier: po.supplier)&.supplier_price
      create_line_item(row, po, variant, price)
      puts "#{index}:line_item created for po #{po.id} with variant ID #{variant.id}"
    end
  rescue => ex
    puts "Error in row #{index}. #{ex.full_message}"
  end

  task :create_for_dh do
    index = 0
    csv_file = Rails.root.join('tmp/csv/distribution_purchase_orders.csv')
    po_list = Hash.new
    CSV.foreach(csv_file, headers: true) do |row|
      index += 1
      if po_list.key? row.fetch('dummy_po_no').to_i
        po = po_list[row.fetch('dummy_po_no').to_i]
      else
        warehouse = Warehouse.find(row.fetch('warehouse_id').to_i)
        po = DhPurchaseOrder.create!(
          warehouse: warehouse,
          quantity: 0,
          total_price: 0,
          created_at: "2020-12-30 20:00:00"
        )
        po_list[row.fetch('dummy_po_no').to_i] = po
        puts "#{index}:New purchase order created with ID #{po.id}"
      end

      variant = Variant.find(row.fetch('variant_id').to_i)
      price = variant.price_consumer
      create_line_item(row, po, variant, price)
      puts "#{index}:line_item created for po #{po.id} with variant ID #{variant.id}"
    end
  rescue => ex
    puts "Error in row #{index}. #{ex.full_message}"
  end

  def create_line_item(row, po, variant, price)
    qc_failed = row.fetch('failed_quantity').to_i
    location = Location.find(row.fetch('location_id').to_i)
    line_item = po.line_items.create!(
      variant: variant,
      quantity: row.fetch('quantity').to_i,
      price: price,
      received_quantity: row.fetch('quantity').to_i,
      qc_passed: row.fetch('quantity').to_i - qc_failed,
      qc_failed: qc_failed,
      qc_status: true,
      location: location
    )

    po.update!(
      quantity: po.quantity + line_item.quantity,
      total_price: po.total_price + (line_item.price.to_d * line_item.quantity)
    )

    if qc_failed > 0
      po.failed_qcs.create!(
        variant: variant,
        quantity: qc_failed,
        failed_reasons: row.fetch('failed_reasons').to_i
      )
    end
  end
end
