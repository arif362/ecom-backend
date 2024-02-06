module ShopothDistributor
  module V1
    module Entities
      class RetailerAssistantDetails < Grape::Entity
        expose :id
        expose :name
        expose :phone
        expose :email, safe: true
        expose :father_name
        expose :experience
        expose :education
        expose :category
        expose :nid
        expose :tech_skill
        expose :date_of_birth
        expose :address
        expose :status

        def address
          {
            address_line: object&.address&.address_line,
            area_id: object&.address&.area&.id,
            area_name: object&.address&.area&.name,
            thana_id: object&.address&.thana&.id,
            thana_name: object&.address&.thana&.name,
            district_id: object&.address&.district&.id,
            district_name: object&.address&.district&.name,
          }
        end
      end
    end
  end
end
