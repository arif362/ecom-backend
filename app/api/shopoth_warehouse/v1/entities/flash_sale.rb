module ShopothWarehouse
  module V1
    module Entities
      class FlashSale < Grape::Entity
        expose :id
        expose :title
        expose :title_bn
        expose :from_date
        expose :to_date
        expose :is_active
        expose :start_time
        expose :end_time
        expose :running
        expose :promotion_category
        expose :promotion_variants, with: ShopothWarehouse::V1::Entities::FlashSaleVariant
        expose :created_by

        def running
          object&.running?
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
