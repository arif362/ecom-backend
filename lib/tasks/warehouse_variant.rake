namespace :warehouse_variant do
  desc 'script for mismatch quantity update of warehouse variant'
  task update_warehouse_variant_quantity: :environment do |_t, _args|
    WarehouseVariant.includes(:stock_changes).all.each do |wv|
      wv.update_columns(
        available_quantity: latest_stock_change(wv).available_quantity,
        booked_quantity: latest_stock_change(wv).booked_quantity,
        packed_quantity: latest_stock_change(wv).packed_quantity,
        in_transit_quantity: latest_stock_change(wv).in_transit_quantity,
        in_partner_quantity: latest_stock_change(wv).in_partner_quantity,
        blocked_quantity: latest_stock_change(wv).blocked_quantity,
      )
      p '<<<<<<<<<<updated>>>>>>>>>>>>'
    end
  end

  private

  def latest_stock_change(warehouse_variant)
    warehouse_variant.stock_changes.order(created_at: :asc).last
  end

end
