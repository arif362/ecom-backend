module ShopothPartner
  module V1
    module Entities
      class PartnerProductsVariants < Grape::Entity
        expose :id
        expose :sku
        expose :price_consumer
        expose :price_discounted do |variant, _options|
          variant.customer_effective_price.to_i
        end
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
          object.price_retailer&.ceil
        end

        def price_consumer
          object.price_consumer.ceil
        end

        def b2b_details
          return unless options[:b2b]
          return if object.product&.b2c?

          {
            b2b_price: object.b2b_price&.ceil,
            b2b_discounted_price: object.b2b_effective_price&.to_i,
            b2b_discount: object.b2b_discount
          }
        end
      end
    end
  end
end
