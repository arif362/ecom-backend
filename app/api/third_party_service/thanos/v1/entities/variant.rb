# frozen_string_literal: true

module ThirdPartyService
  module Thanos
    module V1
      module Entities
        class Variant < Grape::Entity
          expose :id, as: :variant_id
          expose :unique_id, as: :variant_unique_id
          expose :product_id
          expose :product_unique_id
          expose :consumer_discount
          expose :price_consumer

          def product_unique_id
            object.product&.unique_id
          end
        end
      end
    end
  end
end
