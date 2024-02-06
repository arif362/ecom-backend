module ShopothWarehouse
  module V1
    module Entities
      class ReconciliationRoutes < Grape::Entity
        expose :id
        expose :title
        expose :sr_name
        expose :sr_point
        expose :bn_title
        expose :phone
        # expose :collected
        expose :prepaid_order_count
        expose :total_order
        expose :collected_by_sr
        expose :collected_by_fc
        expose :distributor_name
        #expose :total_amount
        #expose :due

        # def due
        #   total_amount = object.total_amount.present? ? object.total_amount : 0
        #   collected =  object.collected.present? ? object.collected : 0
        #   total_amount - collected
        # end

        def distributor_name
          Route.find_by(id: object.id).distributor&.name || ''
        end
      end
    end
  end
end
