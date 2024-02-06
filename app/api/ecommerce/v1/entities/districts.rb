module Ecommerce
  module V1
    module Entities
      class Districts < Grape::Entity
        expose :id, as: :district_id
        expose :name, as: :district_name
        expose :bn_name, as: :bn_district_name
        expose :warehouse_id
        expose :warehouse_name
        expose :sub_domain
        expose :warehouse_type
        expose :public_visibility

        def warehouse_name
          warehouse&.name
        end

        def sub_domain
          if warehouse&.warehouse_type == Warehouse::WAREHOUSE_TYPES[:member]
            "#{ENV['MEMBER_WAREHOUSE']}"
          elsif warehouse&.warehouse_type == Warehouse::WAREHOUSE_TYPES[:b2b]
            "#{ENV['B2B_WAREHOUSE']}"
          else
            ''
          end
        end

        def warehouse_type
          warehouse&.warehouse_type
        end

        def public_visibility
          warehouse&.public_visibility
        end

        def warehouse
          object&.warehouse
        end
      end
    end
  end
end
