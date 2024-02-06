module Ecommerce::V1::Serializers
  module CustomerOrderSerializer
    extend Grape::API::Helpers

    def get_customer_orders(orders)
      Jbuilder.new.key do |json|
        json.array! orders do |order|
          json.order_id order.id
          json.ordered_on order.created_at
          json.delivered_on get_order_on(order)
          json.total order.total_price&.ceil
          json.status order.status&.customer_order_status
          json.bn_status I18n.locale == :bn ? I18n.t("order_status.#{order.status&.order_type}") : ''
        end
      end
    end

    def get_specific_order_details(order)
      Jbuilder.new.key do |json|
        if (order.status.completed? || order.status.partially_returned?) && (order.completed_order_status_date + 7.day) >= Date.today
          json.is_returnable true
        else
          json.is_returnable false
        end
        json.order_tracking_id order.id
        json.all_order_status get_tracking_obj(order.customer_order_status_changes)
        json.default_order_status OrderStatus::CUSTOMER_ORDER_TRACKING
        json.order_id order.id
        json.shipping_charge order.shipping_charge
        json.total_discount order.total_discount_amount&.floor
        json.total_price order.cart_total_price&.ceil
        json.vat_shipping_charge order.vat_shipping_charge
        json.total_payable order.total_price&.ceil
        json.partner_id order.partner&.id
        json.partner_name order.partner&.name
        json.pay_type order.pay_type
        # TODO: next line is giving error as no trx id, it will be commented out after this field is migrated
        # json.trx_id order.payments.find_by(paymentable_type: 'User')&.trx_id || ''
        json.trx_id ''
        json.shipping_address do |_shipping_address|
          if order.home_delivery? || order.express_delivery?
            json.name order.shipping_address&.name
            json.phone order.shipping_address&.phone
            json.thana order.shipping_address&.thana&.name
            json.area order.shipping_address&.area&.name
            json.district order.shipping_address&.district&.name
            json.address_line order.shipping_address&.address_line
          else
            json.name order.partner&.address&.name
            json.phone order.partner&.address&.phone
            json.thana order.partner&.address&.thana&.name
            json.area order.partner&.address&.area&.name
            json.district order.partner&.address&.district&.name
            json.address_line order.partner&.address&.address_line
          end
        end
        json.items order.shopoth_line_items do |item|
          json.product_title product(item.variant_id).title
          json.product_bn_title product(item.variant_id).bn_title
          json.product_image product(item.variant_id)&.hero_image.service_url
          json.shopoth_line_item_id item.id
          json.quantity item.quantity
          json.total item.sub_total&.ceil
          json.product_id product(item.variant_id).id
        end
      end
    end

    def get_tracking_obj(changes)
      result = {}
      changes.each do |c|
        if should_include_status?(c&.order_status&.customer_order_status)
          result[c.id] = {
            status: c&.order_status&.customer_order_status,
            time: c.updated_at
          }
        end
      end
      result
    end
    def should_include_status?(status)
      ['order_delivered_to_partner', 'order_in_transit_partner_switch', 'order_placed'].include?(status) ? false : true
    end

    def get_order_on(order)
      case order.shipping_type
      when 'home_delivery', 'pick_up_point'
        (order.created_at + 72.hours)
      when 'express_delivery'
        (order.created_at + 3.hours)
      else
        order.created_at
      end
    end

    def product(variant_id)
      variant = Variant.unscoped.find_by(id: variant_id)
      Product.unscoped.find_by(id: variant.product_id)
    end
  end
end
