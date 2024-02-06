require 'csv'
namespace :sto do
  desc 'Create IGT and completed with QC'
  task :create, [:starting_rto_id, :ending_rto_id] => :environment do |t, args|
    ActiveRecord::Base.transaction do
      ReturnTransferOrder.
        where('id >= :start_id and id <= :end_id',start_id: args.starting_rto_id, end_id: args.ending_rto_id).
        each_with_index do |rto, index|
        puts "################# Processing RTO No: #{index+1} #################"
        variants = rto.line_items.map {|rto_li| {variant_id: rto_li.variant_id, quantity: rto_li.quantity}}
        dh_po = create_dh_purchase_orders_with_line_items(variants, dhaka_warehouse.id)

        line_item_ids = dh_po.line_items.ids
        line_items = dh_po.boxable_check(line_item_ids, line_item_ids.size)
        dh_po.create_box(line_items[:items], central_staff.id)
        puts 'Create Box Successful'
        dh_pack(dh_po.id)
        in_transit_and_received_to_dh(dh_po.id)
        dh_quality_control(dh_po.id)
        dh_assign_warehouse_variant_location(dh_po.id)
      end
    end

    p "Successfully Transfer Variant From Central to Dhaka Warehouse Through STO From RTO..!!"

  # rescue StandardError => error
  #   p "failed to transfer due to #{error.message}"
  end

  private
  def create_dh_purchase_orders_with_line_items(entities, warehouse_id)
    purchase_orders_n_line_items = {}
    total_price = 0
    total_quantity = 0
    line_items = entities.map do |entity|
      variant_id = entity[:variant_id]
      warehouse_id = warehouse_id
      quantity = entity[:quantity]
      variant = Variant.find(variant_id)
      price = variant.price_distribution.to_d
      total_price += price * quantity.to_d
      total_quantity += quantity
      initialize_line_item(price, variant_id, quantity)
    end.flatten.compact
    purchase_order = create_purchase_order(total_price, total_quantity, warehouse_id)
    items = save_line_items_n_assign_order(purchase_order, line_items)
    purchase_orders_n_line_items[:dh_purchase_order] = purchase_order.as_json.merge({ line_items: items }.as_json)
    puts 'Create DhPurchaseOrder Successful'
    purchase_order
  end

  def fetch_price(variant, supplier)
    supplier_variant = SuppliersVariant.find_by(variant_id: variant, supplier_id: supplier)
    supplier_variant&.supplier_price
  end

  def create_purchase_order(total_price, quantity, warehouse_id)
    DhPurchaseOrder.create!(warehouse_id: warehouse_id,
                        quantity: quantity,
                        total_price: total_price,
                        order_date: DateTime.now)
  end

  def initialize_line_item(price, variant_id, quantity)
    LineItem.new(variant_id: variant_id, quantity: quantity, price: price)
  end

  def save_line_items_n_assign_order(order, items)
    items.map do |item|
      item.update!(itemable: order)
    end
  end

  def product(variant_id)
    @product = Variant.find(variant_id)&.product
  end

  def dh_pack(dh_po_id)
    dh_po = DhPurchaseOrder.find(dh_po_id)
    box = dh_po.boxes.unpacked.first
    line_items = create_dh_required_line_items_for_pack(box)

    order_updated = dh_po_stock_update(dh_po, line_items)
    fail StandardError, "Line items isn't updated properly." unless order_updated

    box.update!(status: :packed)
    if dh_po.all_boxed? == true
      dh_po.update!(order_status: DhPurchaseOrder.getOrderStatus(:ready_to_ship), changed_by: central_staff)
    end
    puts 'Pack Successful'
  end

  def create_dh_required_line_items_for_pack(box)
    line_items = []
    box.line_items.each do |li|
      require_quantity = li.quantity
      wv = WarehouseVariant.find_by(variant_id: li.variant.id, warehouse_id: central_warehouse.id)
      wv.warehouse_variants_locations.where('quantity>0').each do |wvl|
        send_quantity = wvl.quantity
        send_quantity = require_quantity if wvl.quantity > require_quantity
        line_items << {
          line_item_id: li.id,
          location_id: wvl.location_id,
          sku: li.variant.sku,
          quantity: send_quantity
        }
        require_quantity -= send_quantity
        break if require_quantity.zero?
      end
      fail StandardError, "Mismatch warehouse available quantity with warehouse location quantity for warehouse_variant #{wv.id}" unless require_quantity >= 0
    end
    line_items
  end
  
  def dh_po_stock_update(return_customer_order, items, warehouse = central_warehouse)
    updated_quantity_count = 0
    ActiveRecord::Base.transaction do
      items.each do |item|
        send_quantity = item[:quantity]
        sku = item[:sku]
        line_item = return_customer_order.line_items.find_by(id: item[:line_item_id])
        warehouse_variant = line_item.variant.warehouse_variants.find_by(warehouse: warehouse)
        wv_location = warehouse_variant.warehouse_variants_locations.find_by(location_id: item[:location_id])
        unless send_quantity <= warehouse_variant.available_quantity && send_quantity <= wv_location.quantity
          fail StandardError, "Quantity not available for sku: #{line_item.variant.sku}."
        end

        wv_location.update!(quantity: (wv_location.quantity - send_quantity))
        line_item.update!(qr_code: sku, send_quantity: line_item.send_quantity + send_quantity)
        updated_quantity_count += 1
      end
    end
    items.count == updated_quantity_count
  end

  def in_transit_and_received_to_dh(dh_po_id)
    dh_po = DhPurchaseOrder.find(dh_po_id)
    if dh_po.order_status == 'ready_to_ship' && dh_po.all_boxed? == true
      dh_po.update!(order_status: DhPurchaseOrder.getOrderStatus(:in_transit), changed_by: central_staff)
      dh_po.update!(order_status: DhPurchaseOrder.getOrderStatus(:received_to_dh), changed_by: dhaka_staff)
    end
    puts 'InTransit and ReceivedToWh Successful'
  end

  def dh_quality_control(dh_po_id)
    order = DhPurchaseOrder.received_to_dh.find(dh_po_id)
    fail StandardError, "STO not found into received_to_dh." unless order
    order.line_items.each do |dh_po_li|
      # puts "quantity: #{dh_po_li.quantity} for variant #{dh_po_li.variant_id}"
      line_item_context = QualityControl::ProcessQc.call(order_id: dh_po_id,
                                                         order_type: "DhPurchaseOrder",
                                                         variant_id: dh_po_li.variant_id,
                                                         warehouse_id: dhaka_warehouse.id,
                                                         received_quantity: dh_po_li.quantity,
                                                         passed_quantity: dh_po_li.quantity,
                                                         failed_quantity: 0,
                                                         failed_reasons: [],
                                                         current_staff: dhaka_staff)
      fail StandardError, "qc failed for variant #{dh_po_li.variant_id}" unless line_item_context.success?
    end
    puts 'QC Successful'
  end

  def dh_assign_warehouse_variant_location(dh_po_id, warehouse = dhaka_warehouse)
    rto_rows = []

    dh_po = DhPurchaseOrder.find(dh_po_id)
    dh_po.line_items.each do |dh_po_li|
      wv = WarehouseVariant.find_by(warehouse_id: warehouse.id, variant_id: dh_po_li.variant_id)
      unless wv
        wv = warehouse.warehouse_variants.create!(variant_id: dh_po_li.variant_id)
      end
      wvl = wv.warehouse_variants_locations.order(quantity: :desc).last
      unless wvl
        wvl = wv.warehouse_variants_locations.create!(location: warehouse.locations.first, quantity: 0)
      end
      wv.update!(available_quantity: wv.available_quantity + dh_po_li.qc_passed)
      wvl.update!(quantity: (wvl.quantity + dh_po_li.qc_passed))
      wv.save_stock_change('location_assign_after_inbound_qc', dh_po_li.qc_passed, dh_po_li.itemable, nil, 'available_quantity_change')
      rto_rows << [dh_po_id, wvl.id, dh_po_li.qc_passed]
    end
    puts 'Location Assign Successful'
    rto_rows
  end
  def central_staff
    Staff.find_by!(id:189, email: 'cwh_script@agami.ltd')
  end

  def dhaka_staff
    Staff.find_by!(id:190, email: 'dhk_script@agami.ltd')
  end

  def central_warehouse
    Warehouse.find(4)
  end

  def dhaka_warehouse
    Warehouse.find(8)
  end
end
