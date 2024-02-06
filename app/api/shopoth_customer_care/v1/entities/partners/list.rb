module ShopothCustomerCare
  module V1
    module Entities
      module Partners
        class List < Grape::Entity
          expose :id, as: :partner_id
          expose :name
          expose :address
          expose :district
          expose :thana
          expose :area

          def address
            object.address&.address_line
          end

          def district
            object.address&.district&.name
          end

          def thana
            object.address&.thana&.name
          end

          def area
            object.address&.area&.name
          end

        end
      end
    end
  end
end
