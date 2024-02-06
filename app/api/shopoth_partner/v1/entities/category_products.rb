module ShopothPartner
  module V1
    module Entities
      class CategoryProducts < Grape::Entity
        expose :id, as: :product_id
        expose :title
        expose :bn_title
        expose :brand
        expose :get_product_base_price, as: :price
        expose :discount, as: :discount_percentage
        expose :discounted_price
        expose :image
        expose :b2b_details, merge: true

        def get_product_base_price
          object.get_product_base_price_partner(options[:warehouse])&.ceil
        end

        def discounted_price
          object.partner_discounted_price(options[:warehouse])&.ceil
        end

        def image
          object.get_app_img("small")
        end

        def b2b_details
          return unless options[:b2b]
          {
            b2b_discounted_price: object.b2b_partner_discounted_price(options[:warehouse])&.ceil,
            b2b_price: object.b2b_get_product_base_price_partner(options[:warehouse])&.ceil,
            b2b_discount: object.b2b_discount
          }
        end
      end
    end
  end
end
