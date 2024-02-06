module ShopothPartner
  module V1
    module Entities
      class PartnerList < Grape::Entity
        expose :id
        expose :name
        expose :phone
        expose :partner_code
        expose :retailer_code
      end
    end
  end
end
