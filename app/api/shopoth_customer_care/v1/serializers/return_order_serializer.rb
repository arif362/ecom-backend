module ShopothCustomerCare::V1::Serializers
  module ReturnOrderSerializer
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

    def return_details_customer(return_order)
      return_option = fetch_return_option(return_order)
      customer_return_order = {
        id: return_order.id,
        backend_id: return_order.backend_id,
        order_id: return_order.customer_order&.backend_id,
        order_backend_id: return_order.customer_order_id,
        date: return_order.created_at,
        item_title: return_order.shopoth_line_item&.variant&.product&.title,
        price: return_order.shopoth_line_item&.price,
        return_status: return_order.return_status.titleize,
        return_type: return_order.return_type.titleize,
        return_reason: return_order.reason,
        description: return_order.description,
        preferred_delivery_date: return_order.preferred_delivery_date,
        form_of_return: return_order.form_of_return.titleize,
        return_option: return_option[0],
        return_option_value: return_option[1],
        payment_type: pay_type(return_order),
        total_discount_amount: return_order.customer_order&.total_discount_amount,
        is_customer_paid: return_order.customer_order&.is_customer_paid,
        distributor_name: return_order.distributor&.name
      }
      customer = if return_order.customer_order.present?
                   unscoped_customer = User.unscoped.find_by(id: return_order.customer_order.customer_id)
                   {
                     id: unscoped_customer.id,
                     name: unscoped_customer.name,
                     phone: unscoped_customer.phone,
                     email: unscoped_customer.email,

                   }
                 else
                   {}
                 end

      rider = if return_order.rider_id.present?
                {
                  name: return_order.rider&.name,
                  phone: return_order.rider&.phone,
                }
              else
                {}
              end

      order_details = order_details(return_order)
      {
        return_details: customer_return_order,
        customer: customer, rider: rider,
        return_order_details: order_details
      }
    end

    def fetch_return_option(order)
      option = order&.form_of_return
      return [] unless %w(from_home to_partner).include?(option.to_s)

      option_value = ReturnCustomerOrder.form_of_returns[option]
      option_name = option == 'from_home' ? 'collect from home' : 'return to partner'
      [option_name, option_value]
    end

    def shipping_type(return_order)
      return_order.form_of_return&.humanize
    end

    def pay_type(return_order)
      return_order.customer_order&.pay_type&.titleize
    end

    def order_details(order)
      call_center_data = get_specific_order_details(order)
      call_center_data.merge(returned_items: [])
    end

    def get_specific_order_details(order)
      Jbuilder.new.key do |json|
        json.id order.customer_order&.id
        json.sub_total order.shopoth_line_item&.sub_total
        json.total_discount order.customer_order&.total_discount_amount
        json.shipping_charge order.packed? ? order.customer_order.shipping_charge : order.aggregate_return&.pick_up_charge
        json.vat_shipping_charge order.packed? ? order.customer_order.vat_shipping_charge : order.aggregate_return&.vat_shipping_charge
        json.total_price total_price(order.shopoth_line_item&.sub_total, order.customer_order&.shipping_charge)
        json.warehouse_id order.customer_order&.warehouse_id
        json.warehouse_name order.customer_order&.warehouse&.name
        if order.customer_order&.shipping_address.present?
          json.shipping_address do |_shipping_address|
            json.name order.customer_order&.shipping_address&.name
            json.phone order.customer_order&.shipping_address&.phone
            json.area order.customer_order&.shipping_address&.area&.name
            json.thana order.customer_order&.shipping_address&.thana&.name
            json.district order.customer_order&.shipping_address&.district&.name
            json.zip_code order.customer_order&.shipping_address&.zip_code
          end
        end
        if order.customer_order&.billing_address.present?
          json.billing_address do |_billing_address|
            json.name order.customer_order&.billing_address&.name
            json.phone order.customer_order&.billing_address&.thana&.name
            json.area order.customer_order&.billing_address&.area&.name
            json.thana order.customer_order&.billing_address&.thana&.name
            json.district order.customer_order&.billing_address&.district&.name
            json.zip_code order.customer_order&.billing_address&.zip_code
          end
        end
        if order.customer_order&.warehouse.present?
          json.customer_order&.warehouse do |_warehouse|
            json.name _warehouse&.name
            json.phone _warehouse&.phone
          end
        end
        if order.customer_order&.partner_id.present?
          json.partner_details do |_partner|
            json.id order.customer_order&.partner&.id
            json.name order.customer_order&.partner&.name
            json.phone order.customer_order&.partner&.phone
            json.district order.customer_order&.partner&.address&.district&.name
            json.thana order.customer_order&.partner&.address&.thana&.name
            json.area order.customer_order&.partner&.address&.area&.name
            json.zip_code order.customer_order&.partner&.address&.zip_code
            json.schedule order.customer_order&.partner&.schedule
          end
        end
        if order.customer_order&.partner_id.present?
          json.router_details do |_route|
            json.title order.customer_order&.partner&.route&.title
            json.phone order.customer_order&.partner&.route&.phone
          end
        end
        if order.customer_order&.rider_id.present?
          json.rider_details do |_rider|
            json.name order.customer_order&.rider&.name
            json.phone order.customer_order&.rider&.phone
          end
        end

        # json.order_tracking get_tracking_obj(order.return_customer_orders)
        json.items current_item(order.shopoth_line_item, order)
      end
    end

    def total_price(item_total, shipping_charge)
      item_total = item_total.present? ? item_total : 0
      shipping_charge = shipping_charge.present? ? shipping_charge : 0
      item_total - shipping_charge
    end

    def current_item(item, order)
      result = []
      if order.packed?
        items = order&.customer_order&.shopoth_line_items
        items.each do |itm|
          result << {
            product_title: itm&.variant&.product&.title,
            product_image: itm&.variant&.product&.hero_image&.service_url,
            shopoth_line_item_id: itm&.id,
            quantity: itm.quantity,
            price: itm&.price,
            discount_amount: itm&.discount_amount,
            sub_total: itm&.sub_total,
            total: itm&.sub_total,
            item: item(itm),
          }
        end
      elsif order.unpacked?
        quantity = 1
        result << {
          product_title: item&.variant&.product&.title,
          product_image: item&.variant&.product&.hero_image&.service_url,
          shopoth_line_item_id: item&.id,
          quantity: quantity,
          price: item&.price,
          discount_amount: item&.discount_amount,
          sub_total: item&.sub_total,
          total: item&.sub_total,
          item: item(item),
        }
      else
        quantity = 0
      end
      result
    end

    def get_returned_items(return_customer_orders)
      result = []
      return_customer_orders.each do |return_order|
        result << {
          id: return_order.id,
          backend_id: return_order.backend_id,
          date: return_order.created_at,
          item_title: return_order.shopoth_line_item&.variant&.product&.title,
          price: return_order.shopoth_line_item&.price,
          return_status: return_order.return_status,
          item: item(return_order.shopoth_line_item),
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
            is_deleted: at.is_deleted,
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

    def get_tracking_obj(return_customer_orders)
      result = []
      return_customer_orders.each do |return_order|
        result << {
          status: return_order&.return_status&.humanize,
          time: return_order.updated_at,
        }
      end
      result
    end
  end
end
