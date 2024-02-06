module ShopothWarehouse
  module V1
    module Entities
      class PromoCouponRules < Grape::Entity
        expose :id
        expose :ruleable_type
        expose :ruleable_id
        expose :parent_history

        def parent_history
          history = {}
          case object.ruleable_type
          when 'Area'
            obj = object.ruleable
            history[:thana_id] = obj&.thana_id
            obj = obj.thana
            history[:district_id] = obj&.district_id
            obj = obj.district
            history[:warehouse_id] = obj.warehouse_id
          when 'Thana'
            obj = object.ruleable
            history[:district_id] = obj&.district_id
            obj = obj.district
            history[:warehouse_id] = obj.warehouse_id
          when 'District'
            obj = object.ruleable
            history[:warehouse_id] = obj&.id
          end
          history
        end
      end
    end
  end
end
