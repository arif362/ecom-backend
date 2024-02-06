module ShopothPartner
  module V1
    module Entities
      class BnCartCreation < Grape::Entity
        expose :id, as: :shopoth_line_item_id
        expose :variant_id
        expose :quantity
        expose :price, as: :unit_price
        expose :cart_id
        expose :discount_amount
        expose :sub_total
        expose :cart_info
        expose :total_items

        def cart_info
          {
            cart_total_items: object.cart.total_items.to_s.to_bn,
            cart_sub_total: object.cart.sub_total.ceil.to_s.to_bn,
            cart_discount: object.cart.cart_discount.floor.to_s.to_bn,
            cart_total_discount: object.cart.total_discount.to_s.to_bn,
            cart_total_price: object.cart.total_price.ceil.to_s.to_bn,
          }
        end

        def price
          object.price.ceil.to_s.to_bn
        end

        def discount_amount
          object.discount_amount.floor.to_s.to_bn
        end

        def sub_total
          object.sub_total.ceil.to_s.to_bn
        end

        def total_items
          object.cart.shopoth_line_items.count.to_s.to_bn
        end

        def quantity
          object.quantity.to_s.to_bn
        end
      end
    end
  end
end
