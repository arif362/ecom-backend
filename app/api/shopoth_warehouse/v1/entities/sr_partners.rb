module ShopothWarehouse
  module V1
    module Entities
      class SrPartners < Grape::Entity
        expose :id
        expose :name
        expose :phone
        expose :due_payment

        def due_payment
          object.due_payment.ceil
        end

        def name
          options[:language] == 'bn' ? object.bn_name : object.name
        end
      end
    end
  end
end
