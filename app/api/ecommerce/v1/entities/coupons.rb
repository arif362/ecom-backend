module Ecommerce
  module V1
    module Entities
      class Coupons < Grape::Entity
        expose :id
        expose :code
        expose :discount_amount
        expose :is_used
        expose :discount_type
        expose :max_limit
        expose :end_at
      end
    end
  end
end
