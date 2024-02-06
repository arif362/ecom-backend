module ShopothPartner
  module V1
    module Entities
      class CartCreation < Grape::Entity
        expose :id, as: :shopoth_line_item_id
        expose :variant_id
        expose :quantity
        expose :price, as: :unit_price
        expose :cart_id
        expose :discount_amount
        expose :sub_total
        expose :sample_for
        expose :cart_info
        expose :total_items

        def cart_info
          {
            cart_total_items: object.cart.total_items,
            cart_sub_total: object.cart.sub_total.ceil,
            cart_discount: object.cart.cart_discount.floor,
            cart_total_discount: object.cart.total_discount.ceil,
            cart_total_price: object.cart.total_price.ceil,
          }
        end

        def price
          object.price.ceil
        end

        def discount_amount
          object.discount_amount.floor
        end

        def sub_total
          object.sub_total.ceil
        end

        def total_items
          object.cart.shopoth_line_items.count
        end
      end
    end
  end
end
