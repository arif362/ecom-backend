module Ecommerce
  module V1
    module Entities
      class Carts < Grape::Entity
        expose :id, as: :cart_id
        expose :sub_total
        expose :total_items
        expose :cart_discount
        expose :cart_dis_type, as: :cart_discount_type
        expose :total_price
        expose :min_cart_value
        expose :shipping_charges
        expose :coupon_code
        expose :shopoth_line_items
        expose :tenures
        expose :emi_available?, as: :is_emi_available

        def total_items
          object.shopoth_line_items.to_a.sum(&:quantity)
        end

        def cart_discount
          object.cart_discount.ceil
        end

        def total_price
          object.total_price&.ceil
        end

        def min_cart_value
          Configuration.min_cart_value
        end

        def shipping_charges
          object.calculate_shipping_charges
        end

        def coupon_code
          object.coupon_code
        end

        def tenures
          object.fetch_tenures
        end

        def emi_available?
          object.check_emi_availability
        end

        def shopoth_line_items
          Ecommerce::V1::Entities::ShopothLineItems.represent(object.shopoth_line_items,
                                                              warehouse: options[:warehouse],
                                                              list: options[:list])
        end
      end
    end
  end
end
