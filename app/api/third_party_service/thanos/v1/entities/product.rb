# frozen_string_literal: true

module ThirdPartyService
  module Thanos
    module V1
      module Entities
        class Product < Grape::Entity
          expose :id, as: :product_id
          expose :unique_id
          expose :variants

          def variants
            variants = []
            object&.variants&.each do |variant|
              variants << {
                variant_id: variant.id,
                unique_id: variant.unique_id,
              }
            end
            variants
          end
        end
      end
    end
  end
end
