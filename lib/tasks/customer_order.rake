require 'csv'

namespace :customer_order do
  desc 'This task will update history returned_from_partner from returned_from_customer for customer order'

  task make_returned_from_partner: :environment do |_t, _args|
    ReturnCustomerOrder.packed.each do |p_re|
      ord = p_re.customer_order
      return_status = OrderStatus.find_by(order_type: :returned_from_customer)
      current_return_status = ord.customer_order_status_changes.find_by(order_status_id: return_status.id)
      ord.update_columns(order_status_id: OrderStatus.find_by(order_type: :returned_from_partner).id)
      current_return_status.update_columns(order_status_id: OrderStatus.find_by(order_type: :returned_from_partner).id)
      puts "--- Updated successfully for ord #{ord}"
    rescue StandardError => error
      puts "--- Error while updating customer_order ord due to: #{error}"
      next
    end
  end

  desc 'This task expires extension for customer order'
  task expire_extension: :environment do |_t, _args|
    orders = CustomerOrder.where(pay_status: %i(non_extended extended),
                                 status: OrderStatus.getOrderStatus(OrderStatus.order_types[:delivered_to_partner]))

    orders.each do |order|
      status_change_date = order&.customer_order_status_changes&.last&.created_at&.beginning_of_day || DateTime.now
      days_passed = (Date.today.beginning_of_day - status_change_date) / 3600 / 24
      # Hide this portion of codes based on requirement.
      # if (order.induced? && days_passed >= 4) || (order.organic? && days_passed >= 9)
      #   order.update(pay_status: :extension_expired)
      # end
      order.update(pay_status: :extension_expired) if days_passed > 180
    end
  rescue StandardError => error
    puts "--- Error while expiring customer_order extension due to: #{error}"
  end

  desc 'This task expires extension for customer order'
  task update_completed_status_creation_date: :environment do |_t, _args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/customer_orders.csv'),
      headers: true, col_sep: ',', header_converters: :symbol,
    )
    csv_file.each do |row|
      index += 1
      data = row.to_h
      order_id = data[:order_id].to_i
      order = CustomerOrder.find(order_id)
      customer_order_status_change = order.customer_order_status_changes.find_or_create_by(order_status_id: 8)
      customer_order_status_change.update_columns(created_at: order.completed_at, updated_at: order.completed_at)
    rescue StandardError => error
      Rails.logger.info "#{error.full_message}"
      puts "Error occurred row number: #{index}, #{error.full_message}"
    end
  end

  desc 'This task updates product sell count for already completed orders'
  task update_sell_count: :environment do |_t, _args|
    orders = CustomerOrder.where(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:completed]))

    orders.each do |order|
      order.shopoth_line_items.each do |line_item|
        product = line_item&.variant&.product
        product&.update(sell_count: (product.sell_count + line_item.quantity))
      end
    end
  rescue => ex
    puts "--- Error while updating product sell count due to: #{ex}"
  end

  desc 'Updating history date for which delivered to partner status date time is greater then completed status creation date'

  task order_status_changed_time_update: :environment do |_t, _args|
    CustomerOrder.where(order_status_id: 8).in_batches(of: 500) do |orders|
      update_time(orders)
    rescue StandardError => error
      puts "--- Error while updating customer_order ord due to: #{error}"
      next
    end
  end

  task pack_order_manually: :environment do |_t, _args|
    order_ids = [55449, 55448, 55442]
    status_ids = [OrderStatus.order_types[:order_placed], OrderStatus.order_types[:order_confirmed]]
    customer_orders = CustomerOrder.where(order_status_id: status_ids, id: order_ids)

    customer_orders.each do |customer_order|
      items = []
      warehouse = customer_order.warehouse

      if customer_order.is_customer_paid == false && !customer_order.cash_on_delivery?
        Rails.logger.error "\nOnly successful online payment should pack , failed to pack order: #{customer_order.id}\n"
        next
      end

      customer_order.shopoth_line_items.each do |pack_item|
        line_item = ShopothLineItem.find(pack_item.id)
        items << line_item
        warehouse_variant = warehouse.warehouse_variants.find_by(variant: line_item.variant)
        warehouse_variant_location = warehouse_variant.warehouse_variants_locations.where('quantity >= ?', line_item.quantity).last

        if (warehouse_variant_location.quantity - line_item.quantity).negative?
          Rails.logger.error "\nWarehouse_variant_location quantity is being negative for warehouse_variant_id: #{warehouse_variant.id} and warehouse_variant_location: #{warehouse_variant_location.id}\n"
        end
        if (warehouse_variant.booked_quantity - line_item.quantity).negative?
          Rails.logger.error "\nBooked_quantity is being negative for sku = #{line_item.variant.sku}and
             warehouse_variant_id: #{warehouse_variant.id}.Action: Customer Order Pack and Line_Item_id: #{line_item.id}\n"
        end

        next if (warehouse_variant_location.quantity - line_item.quantity).negative?
        next if (warehouse_variant.booked_quantity - line_item.quantity).negative?

        line_item.update(qr_codes: get_qr_codes(line_item.quantity, line_item.variant&.sku), location_id: warehouse_variant_location.location_id)
        warehouse_variant_location.update!(quantity: warehouse_variant_location.quantity - line_item.quantity)
      end

      stock_update(items, warehouse)
      order_status_update(customer_order)
      puts " Successfully packed order id : #{customer_order.id}"
    end
  rescue StandardError => error
    puts "--- Error while updating customer_order ord due to: #{error}"
    next
  end

  task :revert_stock_for_one_fc, [:warehouse_id] => [:environment] do |t, args|
    status_ids
    CustomerOrder.where(order_status_id: status_ids, warehouse_id: args.warehouse_id).includes(:shopoth_line_items, warehouse: :warehouse_variants).each do |order|
      order.shopoth_line_items.each do |item|
        warehouse_variant = order.warehouse.warehouse_variants.find_by(variant_id: item.variant_id)
        puts "warehouse_variant id #{warehouse_variant.id}"
        update_stock_to_revert(warehouse_variant, order, item.quantity)
        update_location_to_revert(warehouse_variant, item.quantity)
      end
      puts "--- updated order id #{order.id}"
    end
  end

  task :store_stock_for_one_fc, [:previous_warehouse_id] => [:environment] do |_t, args|
    status_ids
    CustomerOrder.where(order_status_id: status_ids, warehouse_id: args.previous_warehouse_id).includes(:shopoth_line_items, warehouse: :warehouse_variants).each do |order|
      order.update_columns(warehouse_id: 8)
      order.shopoth_line_items.each do |item|
        puts "--- start updated order id #{order.id}"

        warehouse_variant = order.warehouse.warehouse_variants.find_or_create_by(variant_id: item.variant_id)
        puts "--- start updated order id #{order.id}  warehouse_variant id #{warehouse_variant.id} and variant #{item.variant_id}"

        update_stock_to_store(warehouse_variant, order, item.quantity)
        update_location_to_store(warehouse_variant, item.quantity)
      end
      puts "--- end updated order id #{order.id}"
    end
  end

  def update_stock_to_revert(warehouse_variant, order, item_quantity)
    if order.status.order_placed? || order.status.order_confirmed?
      warehouse_variant.update_columns(available_quantity: warehouse_variant.available_quantity + item_quantity,
                                       booked_quantity: warehouse_variant.booked_quantity - item_quantity)
    elsif order.status.ready_to_shipment? || order.status.packed_cancelled?
      warehouse_variant.update_columns(available_quantity: warehouse_variant.available_quantity + item_quantity,
                                       packed_quantity: warehouse_variant.packed_quantity - item_quantity)
    elsif order.status.in_transit? || order.status.in_transit_partner_switch? || order.status.in_transit_delivery_switch? || order.status.in_transit_reschedule? || order.status.in_transit_cancelled?
      warehouse_variant.update_columns(available_quantity: warehouse_variant.available_quantity + item_quantity,
                                       in_transit_quantity: warehouse_variant.in_transit_quantity - item_quantity)
    elsif order.status.delivered_to_partner?
      warehouse_variant.update_columns(available_quantity: warehouse_variant.available_quantity + item_quantity,
                                       in_partner_quantity: warehouse_variant.in_partner_quantity - item_quantity)
    end
  end

  def update_stock_to_store(warehouse_variant, order, item_quantity)
    if order.status.order_placed? || order.status.order_confirmed?
      warehouse_variant.update_columns(available_quantity: warehouse_variant.available_quantity - item_quantity,
                                       booked_quantity: warehouse_variant.booked_quantity + item_quantity)
    elsif order.status.ready_to_shipment? || order.status.packed_cancelled?
      warehouse_variant.update_columns(available_quantity: warehouse_variant.available_quantity - item_quantity,
                                       packed_quantity: warehouse_variant.packed_quantity + item_quantity)
    elsif order.status.in_transit? || order.status.in_transit_partner_switch? || order.status.in_transit_delivery_switch? || order.status.in_transit_reschedule? || order.status.in_transit_cancelled?
      warehouse_variant.update_columns(available_quantity: warehouse_variant.available_quantity - item_quantity,
                                       in_transit_quantity: warehouse_variant.in_transit_quantity + item_quantity)
    elsif order.status.delivered_to_partner?
      warehouse_variant.update_columns(available_quantity: warehouse_variant.available_quantity - item_quantity,
                                       in_partner_quantity: warehouse_variant.in_partner_quantity + item_quantity)
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

  def status_ids
    [OrderStatus.getOrderStatus(OrderStatus.order_types[:order_placed]).id,
     OrderStatus.getOrderStatus(OrderStatus.order_types[:order_confirmed]).id,
     OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_shipment]).id,
     OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit]).id,
     OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit_partner_switch]).id,
     OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit_delivery_switch]).id,
     OrderStatus.getOrderStatus(OrderStatus.order_types[:delivered_to_partner]).id,
     OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit_reschedule]).id,
     OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit_cancelled]).id,
     OrderStatus.getOrderStatus(OrderStatus.order_types[:packed_cancelled]).id,]
  end

  def get_qr_codes(quantity, qr_code)
    qr_codes = []
    quantity.times.each do |_t|
      qr_codes << qr_code
    end
    qr_codes
  end

  def stock_update(items, warehouse)
    wh_variants = WarehouseVariant.group_by_wh_variant(items, warehouse)
    wh_variants.each do |wh_v|
      wh_v['wv_id'].update!(booked_quantity: wh_v['wv_id'].booked_quantity - wh_v['qty'],
                            packed_quantity: wh_v['wv_id'].packed_quantity + wh_v['qty'])
      wh_v['wv_id'].save_stock_change('customer_order_pack', wh_v['qty'], wh_v['stock_changeable'],
                                      'booked_quantity_change', 'packed_quantity_change')
    end
  end

  def order_status_update(customer_order)
    customer_order.update!(
      status: OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_shipment]),
      changed_by: support_staff,
    )
  end

  def support_staff
    Staff.find_by(email: 'developer_cwh@shopoth.com')
  end

  def update_time(orders)
    orders.includes(:customer_order_status_changes).each do |order|
      order_in_partner = order.customer_order_status_changes.find_by(order_status_id: 7)
      order_in_customer = order.customer_order_status_changes.find_by(order_status_id: 8)
      next if order_in_partner.nil? || order_in_customer.nil?
      next if order_in_partner.created_at < order_in_customer.created_at

      replacing_date = order_in_partner.created_at.to_date + 1
      order_in_customer.update_columns(created_at: replacing_date, updated_at: replacing_date)
      order.update_columns(completed_at: replacing_date)
      puts " Successfully updated order id : #{order.id}"
    end
  end

end
