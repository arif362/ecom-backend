require 'csv'
namespace :return_customer_order do
  desc 'This task will revert stock to fc'
  task :revert_return_for_one_fc, [:previous_warehouse_id] => [:environment] do |t, args|

    ReturnCustomerOrder.packed.where(warehouse_id: args.previous_warehouse_id).where.not(return_status: [5, 9]).includes(customer_order: :shopoth_line_items, warehouse: :warehouse_variants).each do |return_order|
      return_order.customer_order.shopoth_line_items.each do |item|
        order = return_order.customer_order
        puts "--- start updated order id #{order.id}"

        warehouse_variant = order.warehouse.warehouse_variants.find_by(variant_id: item.variant_id)
        puts "warehouse_variant id #{warehouse_variant.id}"
        warehouse_variant.update_columns(available_quantity: warehouse_variant.available_quantity + item.quantity)
        update_location_to_revert(warehouse_variant, item.quantity)
      end
    end
  end

  task :store_return_for_one_fc, [:previous_warehouse_id] => [:environment] do |t, args|
    ReturnCustomerOrder.packed.where(warehouse_id: args.previous_warehouse_id).where.not(return_status: [5, 9]).includes(customer_order: :shopoth_line_items, warehouse: :warehouse_variants).each do |return_order|
      order = return_order.customer_order
      puts "--- start updated return_id #{return_order.id} and order id #{order.id}"
      return_order.update_columns(warehouse_id: 8)
      order.update_columns(warehouse_id: 8)
      order.shopoth_line_items.each do |item|

        warehouse_variant = order.warehouse.warehouse_variants.find_or_create_by(variant_id: item.variant_id)
        puts "--- start updated order id #{order.id}  warehouse_variant id #{warehouse_variant.id} and variant #{item.variant_id}"
        puts "warehouse_variant id #{warehouse_variant.id}"
        warehouse_variant.update_columns(available_quantity: warehouse_variant.available_quantity - item.quantity)
        update_location_to_store(warehouse_variant, item.quantity)
      end
    end
  end

  desc 'This task will update consumer price and consumer discount of the given sku'
  task update_return_stock: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/returned_warehouse_variants.csv'),
      headers: true, col_sep: ',', header_converters: :symbol,
    )

    csv_file.each do |row|
      index += 1
      data = row.to_h
      warehouse_variant = WarehouseVariant.find_by(warehouse_id: data[:warehouse_id].to_i, variant_id: data[:variant_id].to_i)
      if warehouse_variant.present?
        warehouse_variant.update_columns(return_in_partner_quantity: data[:return_in_partner_quantity].to_i,
                                         return_in_transit_quantity: data[:return_in_transit_quantity].to_i,
                                         return_in_dh_quantity: data[:return_in_dh_quantity].to_i,
                                         return_in_transit_to_fc_quantity: data[:return_in_transit_to_fc_quantity].to_i,
                                         return_qc_pending_quantity: data[:return_qc_pending_quantity].to_i,
                                         return_location_pending_quantity: data[:return_location_pending_quantity].to_i,)
      end

      puts "#{index}: successfully updated with variant_id - #{data[:variant_id]} "
    rescue StandardError => error
      Rails.logger.info error.full_message.to_s
      puts "Error occurred row number: #{index}, #{error.full_message}"
    end
  end

  def update_location_to_revert(warehouse_variant, item_quantity)
    warehouse_variant_location = warehouse_variant.warehouse_variants_locations.last
    warehouse_variant_location.update_columns(quantity: warehouse_variant_location.quantity + item_quantity)
  end

  def update_location_to_store(warehouse_variant, item_quantity)
    warehouse_variant_location = if warehouse_variant.warehouse_variants_locations.present?
                                   warehouse_variant.warehouse_variants_locations.last
                                 else
                                   warehouse_variant.warehouse_variants_locations.find_or_create_by(location: Location.where(warehouse_id: warehouse_variant.warehouse_id).last)
                                 end
    warehouse_variant_location.update_columns(quantity: warehouse_variant_location.quantity - item_quantity)
  end
end
