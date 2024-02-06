module ShopothWarehouse
  module V1
    module Entities
      class PartnersCustomerOrder < Grape::Entity
        expose :id, as: :order_id
        expose :order_type
        expose :pay_type
        expose :total_price, as: :grand_total
        expose :payments
        # expose :customer, as: :customer_name
        expose :status
        expose :shipping_type
        expose :partner_commission
        expose :delivery_date
        expose :order_date

        def order_date
          object.created_at
        end

        def pay_type
          pay_type = 'Online Payment'
          pay_type = 'Cash on delivery' if object.cash_on_delivery?
          pay_type
        end

        def payments
          object.payments.map do |payment|
            {
              id: payment.id,
              status: payment.status
            }
          end
        end

        def customer
          object.customer&.name
        end

        def status
          object.status.order_type&.humanize
        end

        def shipping_type
          object.shipping_type&.humanize
        end

        def partner_commission
          object.partner_margin&.margin_amount&.round(2)
        end

        def delivery_date
          status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
          date = object.customer_order_status_changes.where(order_status_id: status.id).last&.created_at
        end
      end
    end
  end
end
