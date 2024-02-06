module ShopothCustomerCare
  module V1
    module Entities
      module Partners
        class Details < Grape::Entity
          expose :id
          expose :warehouse_name
          expose :warehouse_bangle_name
          expose :created_at
          expose :warehouse_email
          expose :warehouse_phone
          expose :schedule
          expose :address

          def warehouse_name
            object.route&.warehouse&.name
          end

          def warehouse_email
            object.route&.warehouse&.email
          end

          def warehouse_phone
            object.route&.warehouse&.phone
          end

          def warehouse_bangle_name
            object.route&.warehouse&.bn_name
          end

          def address
            {
              address_line: object.address&.address_line,
              area: object.address&.area&.name,
              thana: object.address&.thana&.name,
              district: object.address&.district&.name,
              post_code: object.address&.zip_code,
            }
          end

          def schedule
            object.schedule&.humanize
          end

        end
      end
    end
  end
end
