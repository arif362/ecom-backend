module Ecommerce
  module V1
    module Entities
      class AggregateReturns < Grape::Entity
        expose :id
        expose :frontend_id
        expose :sub_total
        expose :grand_total, as: :refundable_amount
        expose :pick_up_charge
        expose :vat_shipping_charge
        expose :refunded
        expose :customer_order_id
        expose :created_at
        expose :reschedule_date
        expose :return_count
        expose :order_status
        expose :bn_order_status
        expose :form_of_return
        expose :return_method
        expose :note
        expose :partner
        expose :return_address
        expose :return_ids
        expose :return_items

        def return_count
          return_customer_orders.size
        end

        def order_status
          status.customer_order_status
        end

        def bn_order_status
          status.bn_customer_order_status
        end

        def return_method
          form_of_return == 'from_home' ? 'Home Picked Up' : 'Pick Up Point'
        end

        def form_of_return
          @form_of_return ||= return_customer_orders.first.form_of_return
        end

        def note
          form_of_return == 'from_home' ? 'Rider will collect from your given address' : 'Return will be collected from partner'
        end

        def return_customer_orders
          @return_customer_orders ||= object.return_customer_orders
        end

        def return_address
          if form_of_return == 'from_home'
            Ecommerce::V1::Entities::Address.represent(object&.customer_order&.shipping_address)
          else
            {}
          end
        end

        def partner
          return {} if form_of_return == 'from_home'

          partner ||= object.customer_order&.partner
          {
            id: partner&.id,
            name: partner&.name,
            code: partner&.partner_code,
            address: Ecommerce::V1::Entities::Address.represent(partner&.address),
          }
        end

        def return_ids
          return_customer_orders.map(&:backend_id)
        end

        def return_items
          if options[:list].present?
            []
          else
            Ecommerce::V1::Entities::ReturnCustomerOrders.
              represent(return_customer_orders.order(id: :desc))
          end
        end

        def status
          @status ||= object.customer_order.status
        end
      end
    end
  end
end
