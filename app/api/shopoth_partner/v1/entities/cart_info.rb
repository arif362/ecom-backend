module ShopothPartner
  module V1
    module Entities
      class CartInfo < Grape::Entity
        expose :cart_info
        expose :total_items
        def cart_info
          {
            cart_total_items: object.total_items,
            cart_sub_total: object.sub_total.ceil,
            cart_discount: object.cart_discount.floor,
            cart_total_discount: object.total_discount.floor,
            cart_total_price: object.total_price.ceil,
          }
        end

        def total_items
          object.shopoth_line_items.count
        end
      end
    end
  end
end
