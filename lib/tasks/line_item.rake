namespace :line_item do
  desc 'create line_item if not found and create warehouse_bundle for all warehouse variants'
  task create_line_item: :environment do |t, args|
    variants = Variant.joins(:bundle, :warehouse_variants).where(
      'warehouse_variants.available_quantity > 0',
    ).uniq
    variants.each do |variant|
      variant.warehouse_variants.each do |w_v|
        w_b = WarehouseBundle.find_or_create_by!(bundle_id: variant.bundle.id, warehouse_id: w_v.warehouse_id)
        add_line_item(w_v, w_b)
      end
    end
  end

  def add_line_item(w_v, w_b)
    line_item_quantity = StockChange.bundle_pack.
                         where(warehouse_variant_id: w_v.id).
                         sum(:quantity)

    LineItem.find_or_create_by!(
      variant_id: w_v.variant_id, itemable_type: 'WarehouseBundle',
      itemable_id: w_b.id
    ) do |line_item|
      line_item.quantity = line_item_quantity
      line_item.price = w_v.variant.price_distribution
      line_item.received_quantity = line_item_quantity
      line_item.qc_passed = line_item_quantity
      line_item.qc_status = true
      line_item.send_quantity = line_item_quantity
      line_item.reconcilation_status = 'closed'
      line_item.location_id = w_v.warehouse_variants_locations.order(quantity: :desc).first.location_id
    end
  end
end
