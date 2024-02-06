# frozen_string_literal: true

module Finance
  module V1
    module Entities
      class PaymentReports < Grape::Entity
        expose :id, as: :order_id
        expose :fc_id
        expose :rider_id
        expose :route_id
        expose :partner_id
        expose :shipping_type
        expose :pay_type, as: :payment_type
        expose :total_price, as: :amount
        expose :created_at, as: :order_date
        expose :completed_at
        expose :rider_collected_at
        expose :sr_collected_at
        expose :reconciliation_at
        expose :deposited_at
        expose :received_at

        def fc_id
          object.warehouse_id
        end

        def route_id
          object&.partner&.route_id
        end

        def rider_collected_at
          payments&.find_by(paymentable_type: 'User', receiver_type: 'Rider')&.created_at || ''
        end

        def sr_collected_at
          payments.find_by(paymentable_type: 'Partner', receiver_type: 'Route')&.created_at || ''
        end

        def reconciliation_at
          payments&.find_by(paymentable_type: %w(Route Rider), receiver_type: 'Staff')&.created_at || ''
        end

        def deposited_at
          aggregated_customer_order&.created_at || ''
        end

        def received_at
          aggregated_customer_order&.aggregated_transaction&.bank_transaction&.finance_received_at || ''
        end

        def payments
          @payments ||= object.payments
        end

        def aggregated_customer_order
          @aggregated_customer_order ||= object&.aggregated_transaction_customer_orders&.find_by(transaction_type: 'customer_payment')
        end
      end
    end
  end
end
