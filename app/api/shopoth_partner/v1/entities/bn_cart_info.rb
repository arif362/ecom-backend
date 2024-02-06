module ShopothPartner
  module V1
    module Entities
      class BnCartInfo < Grape::Entity
        expose :cart_info
        expose :total_items
        def cart_info
          {
            cart_total_items: object.total_items,
            cart_sub_total: object.sub_total.ceil.to_s.to_bn,
            cart_discount: object.cart_discount.floor.to_s.to_bn,
            cart_total_discount: object.total_discount.floor.to_s.to_bn,
            cart_total_price: object.total_price.ceil.to_s.to_bn,
          }
        end

        def total_items
          object.shopoth_line_items.count.to_s.to_bn
        end
      end
    end
  end
end
