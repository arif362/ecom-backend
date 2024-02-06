module Ecommerce::V1::Serializers
  module ReturnOrderSerializer
    extend Grape::API::Helpers
    include Ecommerce::V1::Helpers::ImageHelper

    def return_request_details(order)
      Jbuilder.new.key do |json|
        json.order_id order.id
        json.total_items order.item_count
        json.form_of_return fetch_returnable_type(order)
        json.district_id get_district(order)
        json.district_name get_district_name(order)
        json.thana_id get_thana_id(order)
        json.thana_name get_thana_name(order)
        json.area_id get_area_id(order)
        json.area_name get_area_name(order)
        json.address_line fetch_address_line(order)
        json.phone order.phone
        json.name order.name
        json.partner order.partner.present? ? fetch_partner_info(order&.partner) : {}
        json.shopoth_line_items order.shopoth_line_items do |line_item|
          json.id line_item.id
          json.quantity line_item.quantity
          json.requested_quantity line_item.return_customer_orders.count
          json.product_title line_item&.variant&.product&.title
          json.product_attribute_values line_item&.variant&.product_attribute_values do |pa_value|
            json.value pa_value.value
          end
          json.price line_item.price
        end
      end
    end

    def show_items(return_orders)
      Jbuilder.new.key do |json|
        json.array! return_orders do |ret_order|
          json.return_order_id ret_order.id
          json.order_id ret_order.customer_order.id
          json.requested_at ret_order.created_at
          json.status ret_order.return_status
          json.shopoth_line_items do
            json.id ret_order&.shopoth_line_item.id
            json.product_title ret_order&.shopoth_line_item&.variant&.product&.title
            json.product_attribute_values ret_order&.shopoth_line_item&.variant&.product_attribute_values do |pa_value|
              json.value pa_value.value
            end
            json.price ret_order&.shopoth_line_item.sub_total / ret_order&.shopoth_line_item.quantity
          end
        end
      end
    end

    def return_order_list(return_orders)
      Jbuilder.new.key do |json|
        json.array! return_orders do |ret_order|
          json.return_order_id ret_order.id
          json.order_id ret_order.customer_order.id
          json.ordered_on ret_order.customer_order.created_at
          json.requested_at ret_order.created_at
          json.status ret_order.return_status
          json.bn_status I18n.locale == :bn ? I18n.t("return_order_status.#{ret_order.return_status}") : ''
          json.initiated_by ret_order.return_orderable_type
          json.total ret_order.shopoth_line_item.present? ? ret_order.shopoth_line_item&.effective_unit_price : ret_order.customer_order&.total_price
          json.method ret_order.shopoth_line_item.present? ? ret_order.form_of_return.humanize : ret_order.customer_order&.shipping_type&.humanize
        end
      end
    end

    def get_details(return_order)
      Jbuilder.new.key do |json|
        json.return_order_id return_order.id
        json.order_id return_order&.customer_order.id
        json.shopoth_line_item_id return_order&.shopoth_line_item.id
        json.product_id return_order&.shopoth_line_item&.variant&.product&.id
        json.product_title return_order&.shopoth_line_item&.variant&.product&.title
        json.product_attribute_values return_order&.shopoth_line_item&.variant&.product_attribute_values do |pa_value|
          json.value pa_value.value
        end
        json.price return_order&.shopoth_line_item.sub_total / return_order&.shopoth_line_item.quantity
        json.image image_path(return_order&.shopoth_line_item&.variant&.product.main_image)
      end
    end

    def fetch_partner_info(partner)
      Jbuilder.new.key do |json|
        json.id partner.id
        json.name partner.name
        json.phone partner.phone
        json.schedule partner.schedule
        json.outlet_name partner.name
        json.latitude partner.latitude
        json.longitude partner.longitude
        json.slug partner.slug
        json.image fetch_small_image(partner)
        json.address do |_partner_address|
          json.district_id partner.address.district_id
          json.district_name partner.address&.district&.name
          json.thana_id partner.address.thana_id
          json.thana_name partner.address&.thana&.name
          json.area_id partner.address&.area_id
          json.area_name partner.address&.area&.name
          json.address_line partner.address&.address_line
        end
      end
    end

    def get_district(order)
      if order.pick_up_point?
        order&.partner&.address&.district_id
      else
        order&.shipping_address&.district_id
      end
    end

    def get_district_name(order)
      if order.pick_up_point?
        order&.partner&.address&.district&.name
      else
        order&.shipping_address&.district&.name
      end
    end

    def get_thana_id(order)
      order.pick_up_point? ? order&.partner&.address&.thana_id : order&.shipping_address&.thana_id
    end

    def get_thana_name(order)
      order.pick_up_point? ? order&.partner&.address&.thana&.name : order&.shipping_address&.thana&.name
    end

    def get_area_id(order)
      order.pick_up_point? ? order&.partner&.address&.area_id : order&.shipping_address&.area_id
    end

    def get_area_name(order)
      order.pick_up_point? ? order&.partner&.address&.area&.name : order&.shipping_address&.area&.name
    end

    def fetch_small_image(partner)
      image_variant_path(partner&.image)&.dig(:small_img)
    rescue ActiveStorage::FileNotFoundError
      nil
    rescue => _error
      nil
    end

    def fetch_address_line(order)
      order.pick_up_point? ? order&.partner&.address&.address_line : order&.shipping_address&.address_line
    end

    def fetch_returnable_type(order)
      order.pick_up_point? ? 'to_partner' : 'from_home'
    end
  end
end
