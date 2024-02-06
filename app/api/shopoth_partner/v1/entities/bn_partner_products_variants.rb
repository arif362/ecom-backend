module ShopothPartner
  module V1
    module Entities
      class BnPartnerProductsVariants < Grape::Entity
        expose :id
        expose :sku
        expose :bn_price_consumer, as: :price_consumer
        expose :price_discounted do |variant, _options|
          (variant.price_consumer.to_d - variant.consumer_discount_amount.to_d).ceil.to_s.to_bn
        end
        expose :consumer_discount
        expose :price_retailer
        expose :sku_case_dimension
        expose :consumer_discount
        expose :available_quantity do |variant, options|
          options[:available_quantity]
        end
        expose :product_attribute_values do |variant, _options|
          ShopothPartner::V1::Entities::PartnerVariantsAttributeValues.represent(
            variant.product_attribute_values, variant: variant.id
          )
        end
        expose :b2b_details, merge: true

        def price_retailer
          object.price_retailer&.ceil.to_s.to_bn
        end

        def bn_price_consumer
          object.price_consumer.ceil.to_s.to_bn
        end

        def consumer_discount
          object.consumer_discount.to_s.to_bn
        end

        def price_consumer
          object.price_consumer.to_s.to_bn
        end

        def b2b_details
          return unless options[:b2b]
          return if object.product&.b2c?

          {
            b2b_price: object.b2b_price&.ceil.to_s.to_bn,
            b2b_discounted_price: object.b2b_effective_price.to_s.to_bn,
            b2b_discount: object.b2b_discount.to_s.to_bn
          }
        end
      end
    end
  end
end
