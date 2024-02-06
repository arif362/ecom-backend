require 'csv'
namespace :stock_changes do
  task update_initial_stock: :environment do |t, args|

    WarehouseVariant.all.each do |warehouse_variant|
      warehouse_variant.stock_changes.create!( stock_transaction_type: :initial_stock,
                                              stock_changeable_type: 'WarehouseVariant',
                                              stock_changeable_id: warehouse_variant.id,
                                              warehouse_id: warehouse_variant.warehouse_id,
                                              variant_id: warehouse_variant.variant_id,
                                              available_quantity: warehouse_variant.available_quantity,
                                              booked_quantity: warehouse_variant.booked_quantity,
                                              packed_quantity: warehouse_variant.packed_quantity,
                                              in_transit_quantity: warehouse_variant.in_transit_quantity,
                                              blocked_quantity: warehouse_variant.blocked_quantity,
                                              in_partner_quantity: warehouse_variant.in_partner_quantity)

      puts "#{warehouse_variant.id}: successfully created with warehouse_variant_id - #{warehouse_variant.id}  and variant_id #{warehouse_variant.variant_id} "
    rescue => ex
      Rails.logger.info "#{ex.full_message}"
      puts "Error occurred row number: #{ex.full_message}"
    end
  end
end
