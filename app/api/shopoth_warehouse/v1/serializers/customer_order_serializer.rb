module ShopothWarehouse::V1::Serializers
  module CustomerOrderSerializer
    extend Grape::API::Helpers

    def get_customer_orders(orders)
      Jbuilder.new.key do |json|
        json.array! orders do |order|
          json.order_id order.id
          json.ordered_on order.created_at&.to_formatted_s(:long_ordinal)
          json.total_price order.total_price
          json.total_discount_amount order.total_discount_amount
          json.status order.status&.customer_order_status&.humanize
          json.shipping_charge order.shipping_charge
          json.shipping_type order.shipping_type
          json.pay_type order.pay_type
        end
      end
    end

    def return_order_details(return_order)
      return_option = fetch_return_option(return_order)
      customer_return_order = {
        id: return_order.id,
        date: return_order.created_at,
        item_title: return_order.shopoth_line_item&.variant&.product&.title,
        price: return_order.shopoth_line_item&.price,
        return_status: return_order.return_status,
        return_reason: return_order.reason,
        shipping_type: shipping_type(return_order),
        return_option: return_option[0],
        return_option_value: return_option[1],
        payment_type: pay_type(return_order),
        total_discount_amount: return_order.customer_order&.total_discount_amount
      }
      if return_order.customer_order.present?
        customer = {
          id: return_order.customer_order.customer.id,
          name: return_order.customer_order.customer.name,
          phone: return_order.customer_order.customer.phone,
          email: return_order.customer_order.customer.email

        }
      else
        customer = {}
      end
      if return_order.rider_id.present?
        rider = {
          name: return_order.rider&.name,
          phone: return_order.rider&.phone
        }
      else
        rider = {}
      end
      order_details = order_details(return_order.customer_order)
      { return_details: customer_return_order, customer: customer, rider: rider, return_order_details: order_details }
    end

    def shipping_type(return_order)
      return_order.customer_order&.shipping_type&.humanize
    end

    def fetch_return_option(order)
      option = order&.form_of_return
      return [] unless %w(from_home to_partner).include?(option.to_s)

      option_value = ReturnCustomerOrder.form_of_returns[option]
      option_name = option == 'from_home' ? 'collect from home' : 'return to partner'
      [option_name, option_value]
    end

    def pay_type(return_order)
      return_order.customer_order&.pay_type&.humanize
    end

    def order_details(order)
      call_center_data = get_specific_order_details(order)
      call_center_data.merge(returned_items: get_returned_items(order.return_customer_orders))
    end

    def get_specific_order_details(order)
      Jbuilder.new.key do |json|
        json.id order.id
        json.sub_total order.cart_total_price
        json.total_discount order.total_discount_amount
        json.shipping_charge order.shipping_charge
        json.total_price order.total_price
        json.warehouse_id order.warehouse_id
        if order.shipping_address.present?
          json.shipping_address do |_shipping_address|
            json.name order.shipping_address&.name
            json.phone order.shipping_address&.phone
            json.area order.shipping_address&.area&.name
            json.thana order.shipping_address&.thana&.name
            json.district order.shipping_address&.district&.name
            json.zip_code order.shipping_address&.zip_code
          end
        end
        if order.billing_address.present?
          json.billing_address do |_billing_address|
            json.name order.billing_address&.name
            json.phone order.billing_address&.thana&.name
            json.area order.billing_address&.area&.name
            json.thana order.shipping_address&.thana&.name
            json.district order.billing_address&.district&.name
            json.zip_code order.billing_address&.zip_code
          end
        end
        if order.warehouse.present?
          json.warehouse do |_warehouse|
            json.name order.warehouse&.name
            json.phone order.warehouse&.phone
          end
        end
        if order.partner_id.present?
          json.partner_details do |_partner|
            json.name order.partner&.name
            json.phone order.partner&.phone
            json.district order.partner&.address&.district&.name
            json.thana order.partner&.address&.thana&.name
            json.area order.partner&.address&.area&.name
            json.zip_code order.partner&.address&.zip_code
            json.schedule order.partner&.schedule
          end
        end
        if order.partner_id.present?
          json.router_details do |_route|
            json.title order.partner&.route&.title
            json.phone order.partner&.route&.phone
          end
        end
        if order.rider_id.present?
          json.rider_details do |_rider|
            json.name order.rider&.name
            json.phone order.rider&.phone
          end
        end

        json.order_tracking get_tracking_obj(order.customer_order_status_changes)
        json.items order.shopoth_line_items do |item|
          json.product_title item&.variant&.product&.title
          json.product_image item&.variant&.product&.hero_image&.service_url
          json.shopoth_line_item_id item&.id
          json.quantity item&.quantity
          json.price item&.price
          json.discount_amount item.discount_amount
          json.total item.sub_total
          json.sub_total item.sub_total
          json.item item(item)
        end
      end
    end

    def customer_order_details(order)
      Jbuilder.new.key do |json|
        json.id order.id
        json.number order.status&.customer_order_status&.humanize
        json.created_at order.created_at
        json.sub_total order.cart_total_price
        json.total_discount order.total_discount_amount
        json.shipping_charge order.shipping_charge
        json.total_price order.total_price
        json.warehouse_id order.warehouse_id
        if order.shipping_address.present?
          json.shipping_address do |_shipping_address|
            json.name order.shipping_address&.name
            json.phone order.shipping_address&.phone
            json.area order.shipping_address&.area&.name
            json.thana order.shipping_address&.thana&.name
            json.district order.shipping_address&.district&.name
            json.zip_code order.shipping_address&.zip_code
          end
        end
        if order.billing_address.present?
          json.billing_address do |_billing_address|
            json.name order.billing_address&.name
            json.phone order.billing_address&.thana&.name
            json.area order.billing_address&.area&.name
            json.thana order.shipping_address&.thana&.name
            json.district order.billing_address&.district&.name
            json.zip_code order.billing_address&.zip_code
          end
        end
        if order.warehouse.present?
          json.warehouse do |_warehouse|
            json.name order.warehouse&.name
            json.phone order.warehouse&.phone
          end
        end
        if order.partner_id.present?
          json.partner_details do |_partner|
            json.name order.partner&.name
            json.phone order.partner&.phone
            json.district order.partner&.address&.district&.name
            json.thana order.partner&.address&.thana&.name
            json.area order.partner&.address&.area&.name
            json.zip_code order.partner&.address&.zip_code
            json.schedule order.partner&.schedule
          end
        end
        if order.partner_id.present?
          json.router_details do |_route|
            json.title order.partner&.route&.title
            json.phone order.partner&.route&.phone
          end
        end
        if order.rider_id.present?
          json.rider_details do |_rider|
            json.name order.rider&.name
            json.phone order.rider&.phone
          end
        end

        json.order_tracking get_tracking_obj(order.customer_order_status_changes)
        json.items order.shopoth_line_items do |item|
          json.product_title item&.variant&.product&.title
          json.product_image item&.variant&.product&.hero_image&.service_url
          json.shopoth_line_item_id item&.id
          json.quantity item&.quantity
          json.price item&.price
          json.discount_amount item.discount_amount
          json.total item.sub_total
        end
      end
    end

    def get_returned_items(return_customer_orders)
      result = []
      return_customer_orders.each do |return_order|
        result << {
          id: return_order.id,
          date: return_order.created_at,
          item_title: return_order.shopoth_line_item&.variant&.product&.title,
          price: return_order.shopoth_line_item&.price,
          return_status: return_order.return_status,
          item: item(return_order.shopoth_line_item)
        }
      end
      result
    end

    def item(shopoth_line_item)
      if shopoth_line_item.present?
        variant = shopoth_line_item.variant
        {
          product_title: variant&.product&.title,
          sku: variant&.sku,
          unit_price: variant&.price_consumer,
          product_attribute_values: product_attribute_values(variant),
        }
      else
        {}
      end
    end

    def product_attribute_values(variant)
      pro_attr_values = []
      if variant.present? && variant.product_attribute_values.present?
        variant.product_attribute_values.each do |at|
          pro_attr_values << {
            id: at.id,
            product_attribute_id: at.product_attribute_id,
            name: at.product_attribute&.name,
            value: at.value,
            bn_name: at.product_attribute&.bn_name,
            bn_value: at.bn_value,
            created_at: at.created_at,
            updated_at: at.updated_at,
            is_deleted: at.is_deleted
          }
        end
      end
      pro_attr_values
    end

    def get_cancelled_order(order)
      Jbuilder.new.key do |json|
        json.order_id order.id
        json.ordered_on order.created_at&.to_formatted_s(:long_ordinal)
        json.total_price order.total_price
        json.total_discount_amount order.total_discount_amount
        json.status order.status&.customer_order_status&.humanize
        json.status order.cancellation_reason
        json.shipping_charge order.shipping_charge
        json.shipping_type order.shipping_type
        json.pay_type order.pay_type
      end
    end

    def get_tracking_obj(changes)
      result = []
      changes.each do |c|
        result << {
          status: c&.order_status&.customer_order_status&.humanize,
          time: c.updated_at
        }
      end
      result
    end
  end
end
