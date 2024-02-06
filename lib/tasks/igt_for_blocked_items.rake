require 'csv'
namespace :igt_for_blocked_items do
  desc 'Making available for IGT from unblock variant csv file which were unblocked but not available in that particular fc'
  task :make_available_from_unblock, [:warehouse_id, :staff_id] => :environment do |_t, args|
    warehouse = Warehouse.find(args.warehouse_id)
    csv = CSV.read(Rails.root.join('tmp/csv/blocked_items.csv'),
                   headers: true, col_sep: ',', header_converters: :symbol)
    csv.each_with_index do |row, i|
      variant = Variant.find(row[:variant_id].to_i)
      warehouse_variant = warehouse.warehouse_variants.find_by(variant: variant)
      wv_location = warehouse_variant.warehouse_variants_locations.last
      next unless wv_location.present?

      available_quantity_update(warehouse_variant, wv_location, row[:quantity].to_i)
      p "successful index: #{i} and variant: #{row[:variant_id]}"

    rescue StandardError => error
      p "failed index: #{i} and variant: #{row[:variant_id]}"
      p "Unblock failed index:#{i} name: #{row[:variant_id]} #{error.full_message}"
      next
    end
  end

  task :make_available_from_failed_qcs, %i(warehouse_id staff_id) => :environment do |_t, args|
    warehouse = Warehouse.find(args.warehouse_id)
    csv = CSV.read(Rails.root.join('tmp/csv/failed_qcs.csv'),
                   headers: true, col_sep: ',', header_converters: :symbol)
    csv.each_with_index do |row, i|
      variant = Variant.find(row[:variant_id].to_i)
      warehouse_variant = warehouse.warehouse_variants.find_by(variant: variant)
      wv_location = warehouse_variant.warehouse_variants_locations.last
      available_quantity_update(warehouse_variant, wv_location, row[:quantity].to_i)
      p "successful index: #{i} and variant: #{row[:variant_id]}"

    rescue StandardError => error
      p "failed index: #{i}"
      p "failed qc received failed index:#{i} name: #{row[:variant_id]} #{error.full_message}"
      next
    end
  end

  desc 'Create IGT and completed with QC'
  task :create_igt, %i(warehouse_id staff_id) => :environment do |_t, args|
    rto_rows = []
    warehouse = Warehouse.find(args.warehouse_id)
    current_staff = Staff.find(args.staff_id)

    ActiveRecord::Base.transaction do
      WarehouseVariant.
        where('warehouse_id = ? and available_quantity > 0', args.warehouse_id).
        find_in_batches(batch_size: 100).
        with_index do |group, batch|
        puts "################# Processing group: #{batch} #################"
        variant_id_with_quantities = group.map do |wv|
          {
            variant_id: wv.variant_id,
            quantity: wv.available_quantity,
          }
        end
        rto_rows += return_transfer_order_full_cycle(warehouse, variant_id_with_quantities, current_staff)
      end
    end

    p "Successfully Make RTO For All Variant Of Warehouse: #{warehouse.name}"
    create_csv_file_to_track_as_rto_id_wvl_id_quantity(warehouse, rto_rows)
  rescue StandardError => error
    p "failed to transfer due to #{error.full_message}"
    create_csv_file_to_track_as_rto_id_wvl_id_quantity(warehouse, rto_rows, 'a')
  end

  private

  def available_quantity_update(warehouse_variant, wv_location, quantity)
    ActiveRecord::Base.transaction do
      warehouse_variant.update!(
        available_quantity: warehouse_variant.available_quantity + quantity,
      )
      wv_location.update!(quantity: wv_location.quantity + quantity)
    end
  end

  def return_transfer_order_full_cycle(warehouse, variant_id_with_quantities, current_staff)
    rto_rows = []
    ActiveRecord::Base.transaction do
      return_orders = create_return_transfer_order(warehouse, variant_id_with_quantities)

      return_orders.each do|return_order|
        line_item_ids = return_order.line_items.ids
        make_box(return_order.id, line_item_ids, current_staff)
        pack(return_order.id, warehouse, current_staff)
        in_transit_and_received_to_wh(return_order.id, current_staff)
        quality_control(return_order.id, cwh_staff)
        central_warehouse = Warehouse.find_by!(warehouse_type: Warehouse::WAREHOUSE_TYPES[:central])
        rto_rows += assign_warehouse_variant_location(return_order.id, central_warehouse)
      end
    end

    rto_rows
  end
  def create_return_transfer_order(warehouse, order_params, return_orders = [])
    executed_params = []

    ActiveRecord::Base.transaction do
      return_order = ReturnTransferOrder.create!(
        warehouse: warehouse,
      )
      total_price = 0
      # p order_params.map{|itm| itm[:variant_id]}

      order_params.each do |item|
        variant = Variant.find_by(id: item[:variant_id])
        total_price += (variant.price_distribution.to_d * item[:quantity])

        if total_price.to_f.truncate.to_s.size > 8
          total_price -= (variant.price_distribution.to_d * item[:quantity])
          fail StandardError, "Single variant #{item[:variant_id]}, amount is exceed " if total_price.zero?

          break
        end

        return_order.create_line_item(variant, item[:quantity])
        executed_params << item
      end
      puts "#count: #{executed_params.length}|total_price:#{total_price}"
      return_order.update!(
        quantity: return_order.line_items.sum(&:quantity),
        total_price: total_price,
      )

      return_orders << return_order
      order_params -= executed_params

      print '#'
      create_return_transfer_order(warehouse, order_params, return_orders) if order_params.length.positive?
    end
    puts 'RTO Create Successful'
    return_orders
  end

  def make_box(rt_order_id, line_item_ids, current_staff)
    rt_order = ReturnTransferOrder.find(rt_order_id)
    line_items = rt_order.boxable_check(line_item_ids, line_item_ids.size)
    if line_items[:boxable] == false
      fail StandardError, 'unable to create box'
    else
      ActiveRecord::Base.transaction do
        rt_order.create_box(line_items[:items], current_staff.id)
      end
    end

    puts 'Box Make Successful'
  end

  def create_required_line_items_for_pack(box, warehouse)
    line_items = []
    box.line_items.each do |li|
      require_quantity = li.quantity
      wv = WarehouseVariant.find_by(variant_id: li.variant.id, warehouse_id: warehouse.id)
      wv.warehouse_variants_locations.where('quantity>0').each do |wvl|
        expected_qty = require_quantity <= wvl.quantity ? require_quantity : wvl.quantity
        line_items << {
          line_item_id: li.id,
          location_id: wvl.location_id,
          sku: li.variant.sku,
          quantity: expected_qty,
        }
        require_quantity -= expected_qty
        next if require_quantity == 0
      end
      fail StandardError, "Mismatch warehouse available quantity with warehouse location quantity for warehouse_variant #{wv.id}" unless require_quantity == 0
    end
    line_items
  end

  def transfer_order_stock_update(return_customer_order, items, warehouse)
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

  def pack(transfer_order_id, warehouse, current_staff)
    transfer_order = ReturnTransferOrder.find(transfer_order_id)
    box = transfer_order.boxes.unpacked.first
    line_items = create_required_line_items_for_pack(box, warehouse)

    order_updated = transfer_order_stock_update(transfer_order, line_items, warehouse)
    fail StandardError, "Line items isn't updated properly." unless order_updated

    box.update!(status: :packed)
    if transfer_order.all_boxed? == true
      transfer_order.update!(order_status: ReturnTransferOrder.getOrderStatus(:ready_to_ship), changed_by: current_staff)
    end
    puts 'Pack Successful'
  end

  def in_transit_and_received_to_wh(rt_order_id, current_staff)
    rt_order = ReturnTransferOrder.find(rt_order_id)
    if rt_order.order_status == 'ready_to_ship' && rt_order.all_boxed? == true
      rt_order.update!(order_status: ReturnTransferOrder.getOrderStatus(:in_transit), changed_by: current_staff)
      rt_order.update!(order_status: ReturnTransferOrder.getOrderStatus(:received_to_cwh), changed_by: cwh_staff)
    end
    puts 'InTransit and ReceivedToWh Successful'
  end

  def quality_control(rto_id, current_staff)
    order = ReturnTransferOrder.received_to_cwh.find(rto_id)
    fail StandardError, 'RTO not found into received_to_cwh.' unless order

    order.line_items.each do |rto_li|
      # puts "quantity: #{rto_li.quantity} for variant #{rto_li.variant_id}"
      line_item_context = QualityControl::ProcessQc.call(order_id: rto_id,
                                                         order_type: 'ReturnTransferOrder',
                                                         variant_id: rto_li.variant_id,
                                                         warehouse_id: current_staff&.warehouse&.id,
                                                         received_quantity: rto_li.quantity,
                                                         passed_quantity: rto_li.quantity,
                                                         failed_quantity: 0,
                                                         failed_reasons: [],
                                                         current_staff: current_staff)
      fail StandardError, "qc failed for variant #{rto_li.variant_id}" unless line_item_context.success?
    end
    puts 'QC Successful'
  end
  def assign_warehouse_variant_location(rto_id, warehouse)
    rto_rows = []

    unless warehouse&.warehouse_type == Warehouse::WAREHOUSE_TYPES[:central]
      fail StandardError, "location assign failed due to #{warehouse.id} is not a central warehouse"
    end

    return_transfer_order = ReturnTransferOrder.find(rto_id)
    return_transfer_order.line_items.each do |rto_li|
      wv = WarehouseVariant.find_by(warehouse_id: warehouse.id, variant_id: rto_li.variant_id)
      wv ||= warehouse.warehouse_variants.create!(variant_id: rto_li.variant_id)
      wvl = wv.warehouse_variants_locations.last
      wvl ||= wv.warehouse_variants_locations.create!(location: warehouse.locations.first, quantity: 0)
      # TODO: for failed qc, should avoid adding qty because we placed sto without reducing the cwh qty for that variant
      # wv.update!(available_quantity: wv.available_quantity + rto_li.qc_passed) # hide for failed qc igt
      # wvl.update!(quantity: (wvl.quantity + rto_li.qc_passed)) # hide for failed qc igt
      wv.save_stock_change('location_assign_after_rto_qc', rto_li.qc_passed, rto_li.itemable, nil, 'available_quantity_change')
      rto_rows << [rto_id, wvl.id, rto_li.qc_passed]
    end
    puts 'Location Assign Successful'
    rto_rows
  end
  def create_csv_file_to_track_as_rto_id_wvl_id_quantity(warehouse, rto_rows, f_mode = 'w')
    filename = "tmp/csv/return_transfer_order_#{warehouse.name.parameterize.underscore}.csv"
    f = File.open(filename, f_mode)
    rto_rows = [%w(return_transfer_order_id location_id quantity)] + rto_rows if f.size.zero?
    f.write(rto_rows.map(&:to_csv).join)
    f.close
  end

  def cwh_staff
    Staff.find_by!(id: 189, email: 'cwh_script@agami.ltd')
  end
end
