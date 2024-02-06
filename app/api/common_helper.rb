# frozen_string_literal: true

module CommonHelper
  extend Grape::API::Helpers

  def prepare_order_history(order_list)
    orders = format_completed_at(order_list)
    grouped_data = orders.group_by(&:completed_at)
    grouped_data.map do |key, val|
      {
        date: format_date(key),
        order_list: process_order_list(val),
      }
    end
  end

  def prepare_return_history(return_list)
    grouped_data = return_list.group_by(&:created_at)
    grouped_data.map do |key, val|
      {
        date: format_date(key),
        order_list: process_return_list(val),
      }
    end
  end

  def format_completed_at(orders)
    orders.map do |order|
      order.update(completed_at: format_date(order.completed_at))
      order
    end
  end

  def format_date(time)
    time&.strftime("%d/%m/%Y")
  end

  def process_order_list(order_list)
    order_list.map do |order|
      address = order.shipping_address
      partner_commission = 0
      # partner_commission = order&.induced? ? order&.partner_commission.to_f : 0
      order_price = order.total_price - partner_commission
      {
        order_id: order.id,
        customer_name: order.customer&.name,
        order_type: order.order_type,
        business_type: order.business_type,
        app_order_type: app_order_type(order.order_type),
        phone: customer_phone(order.customer),
        amount: order_price,
        area: area(address&.area),
      }
    end
  end

  def process_return_list(return_list)
    return_list.map do |return_order|
      address = return_order&.customer_order.shipping_address
      {
        order_id: return_order&.id,
        customer_name: return_order&.customer_order&.customer&.name,
        order_type: return_order&.customer_order&.order_type,
        business_type: return_order&.customer_order&.business_type,
        app_order_type: app_order_type(return_order&.customer_order&.order_type),
        phone: customer_phone(return_order&.customer_order&.customer),
        amount: return_order&.customer_order&.cart_total_price,
        area: area(address&.area),
      }
    end
  end

  def get_hash(title, message)
    { title: title, message: message }
  end

  def customer_phone(customer)
    I18n.locale == :bn ? customer&.phone&.to_s&.to_bn : customer&.phone
  end

  def area(area)
    I18n.locale == :bn ? area&.bn_name : area&.name
  end

  def app_order_type(order_type)
    I18n.locale == :bn ? I18n.t("order_type.#{order_type}") : order_type
  end

  def routes_order_count(sr_received_amount, dh_received_amount, route_return_orders, dh_return_orders, route = nil)
    {
      route_details: {
        title: route&.title || '',
        phone: route&.phone || '',
      },
      cash_collected: {
        route: sr_received_amount,
        dh: dh_received_amount,
      },
      packed_return: {
        route: route_return_orders.select(&:packed?).size,
        dh: dh_return_orders.select(&:packed?).size,
      },
      unpacked_return: {
        route: route_return_orders.select(&:unpacked?).size,
        dh: dh_return_orders.select(&:unpacked?).size,
      },
    }
  end

  def riders_order_count(r_customer_orders, dh_customer_orders, rider_return_orders, dh_return_orders, rider = nil)
    {
      rider_details: {
        name: rider&.name || '',
        phone: rider&.phone || '',
      },
      cash_collected: {
        rider: r_customer_orders,
        dh: dh_customer_orders,
      },
      unpacked_return: {
        rider: rider_return_orders.count,
        dh: dh_return_orders.count,
      },
    }
  end

  def fetch_customer_orders(partner, customer_orders, return_orders)
    total_amount = total_amount(customer_orders)
    collected_amount = collected_amount(customer_orders)
    total_online_payment ||= total_amount(customer_orders.online_payment)

    {
      id: partner.id,
      name: partner.name,
      outlet_name: partner.name,
      route: partner.route_id,
      distributor_name: partner.route&.distributor&.name,
      phone: partner.phone,
      partner_code: partner.partner_code,
      returns: return_orders.count,
      total_orders: customer_orders.count,
      total_amount: total_amount,
      collected: collected_amount,
      due_payment: total_amount - collected_amount - total_online_payment,
      region_name: partner.region || '',
    }
  end

  def total_amount(customer_orders)
    customer_orders&.sum(&:total_price) || 0
  end

  def collected_amount(customer_orders)
    customer_orders.joins(:payments).
      where(payments: { status: :successful, paymentable_type: 'Partner' }).
      sum('payments.currency_amount') || 0
  end

  def update_stock(customer_order, warehouse_id = nil)
    items = customer_order.shopoth_line_items
    wh_variants = WarehouseVariant.group_by_wh_variant(items, warehouse_id)
    wh_variants.each do |wh_v|
      if (wh_v['wv_id'].in_transit_quantity - wh_v['qty']).negative?
        Rails.logger.error "\nIn_transit_quantity is being negative for warehouse_variant_id: #{wh_v['wv_id'].id}.
              Action: Rider -> Receive_customer_order: #{wh_v['stock_changeable'].id}\n"
      end
      wh_v['wv_id'].update!(in_transit_quantity: wh_v['wv_id'].in_transit_quantity - wh_v['qty'],
                            ready_to_ship_quantity: wh_v['wv_id'].ready_to_ship_quantity + wh_v['qty'])
      wh_v['wv_id'].save_stock_change('dh_received_packed_customer_order', wh_v['qty'], wh_v['stock_changeable'],
                                      'in_transit_quantity_change', 'ready_to_ship_quantity_change')
    end
  end
end
