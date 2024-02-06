module ShopothWarehouse
  module V1
    module Entities
      class ContactUs < Grape::Entity
        expose :id
        expose :name
        expose :phone
        expose :message
        expose :email
        expose :created_at
      end
    end
  end
end
