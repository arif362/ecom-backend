# frozen_string_literal: true

module Ecommerce::V1::Serializers
  module CartShowSerializer
    extend Grape::API::Helpers

    def show_item_in_cart(cart, user_domain = '')
      Jbuilder.new.key do |json|
        json.cart_id cart.id
        json.cart_sub_total cart.sub_total
        json.cart_total_items cart.total_items
        json.cart_discount cart.cart_discount.ceil
        json.cart_total_price cart.total_price&.ceil
        json.min_cart_value min_cart_value
        json.shipping_charges shipping_charges(cart)
        json.coupon_code cart.coupon_code || ''
        json.shopoth_line_items cart.shopoth_line_items do |item|
          json.shopoth_line_item_id item.id
          json.quantity item.quantity
          json.price item.price
          json.sub_total item.sub_total&.ceil
          json.discount_amount item.discount_amount&.floor
          json.variant_id item.variant.id
          json.product_id item.variant.product.id
          json.product_title item.variant.product.title
          json.product_image item.variant.product.main_image.service_url
        end
      end
    end

    def min_cart_value
      Configuration.min_cart_value
    end

    def shipping_charges(cart)
      cart.calculate_shipping_charges
    end
  end
end
