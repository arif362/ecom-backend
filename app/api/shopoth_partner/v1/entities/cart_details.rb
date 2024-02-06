module ShopothPartner
  module V1
    module Entities
      class CartDetails < Grape::Entity
        include ShopothPartner::V1::Helpers::ImageHelper

        expose :id, as: :cart_id
        expose :sub_total, as: :cart_sub_total
        expose :total_items, as: :cart_total_items
        expose :cart_discount
        expose :total_price, as: :cart_total_price
        expose :min_cart_value
        expose :shipping_charge
        expose :shopoth_line_items

        def shopoth_line_items
          object.shopoth_line_items.map do |item|
            variant = item.variant
            product = Product.unscoped.find_by(id: variant.product_id, is_deleted: false)
            quantity = item.quantity
            price = item.price
            {
              shopoth_line_item_id: item.id,
              quantity: quantity,
              price: price.ceil,
              total_price: (price * quantity).ceil,
              discount_amount: item.discount_amount.floor,
              consumer_price: variant.price_consumer.ceil,
              sub_total: item.sub_total.ceil,
              variant_id: variant.id,
              product_id: variant.product_id,
              product_title: product_title(variant),
              product_image: product_image((product)),
              max_quantity_per_order: product&.max_quantity_per_order || 0,
              is_available: item.available?(options[:warehouse]),
            }
          end
        end

        def sub_total
          object.sub_total.ceil
        end

        def cart_discount
          object.cart_discount.floor
        end

        def total_price
          object.total_price.ceil
        end

        def product_title(variant)
          product = Product.unscoped.find_by(id: variant.product_id, is_deleted: false)
          "#{product&.title&.to_s} #{variant.product_attribute_values&.map(&:value)&.join('-')&.to_s} (#{variant.sku&.to_s})"
        end

        def shipping_charge
          object.calculate_shipping_charges[:pick_up_point]
        end

        def product_image(product)
          begin
            image_path(product.hero_image)
          rescue => _ex
            nil
          end
        end

        def min_cart_value
          Configuration.min_cart_value
        end
      end
    end
  end
end
