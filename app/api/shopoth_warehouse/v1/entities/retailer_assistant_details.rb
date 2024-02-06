module ShopothWarehouse
  module V1
    module Entities
      class RetailerAssistantDetails < Grape::Entity
        expose :id
        expose :distributor_id
        expose :distributor_name
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
        expose :created_by
        # expose :coupons

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

        def distributor_name
          object&.distributor&.name
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end

        # TODO: if need in future, remove comment
        # def coupons
        #   promotions = Promotion.where(promotion_category: 'ra_discount').joins(:ra_coupons).
        #                where(ra_coupons: { retailer_assistant_id: object })
        #   ShopothPartner::V1::Entities::Promotions.represent(promotions, retailer_assistant: object)
        # end
      end
    end
  end
end
