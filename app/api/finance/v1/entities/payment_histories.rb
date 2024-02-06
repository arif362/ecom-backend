module Finance
  module V1
    module Entities
      class PaymentHistories < Grape::Entity
        expose :id
        expose :warehouse_id
        expose :distributor_id
        expose :distributor_name
        expose :month_and_year
        expose :fc_total_collection
        expose :total_collection
        expose :fc_commission
        expose :agent_commission
        expose :partner_commission
        expose :payable_amount
        expose :return_amount

        def month_and_year
          date = "#{object.month}-01".to_date
          "#{date.strftime('%B')}, #{date.strftime('%Y')}"
        end

        def distributor_name
          object.distributor&.name || ''
        end
      end
    end
  end
end
