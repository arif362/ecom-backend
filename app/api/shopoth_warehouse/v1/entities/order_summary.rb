module ShopothWarehouse
  module V1
    module Entities
      class OrderSummary < Grape::Entity
        expose :total_order
        expose :total
        expose :collected_by_sr
        expose :unpack_return
        expose :pack_return

        def total_order
          object[:customer_orders].count
        end

        def total
          amount = 0
          object[:customer_orders].each do |customer_order|
            currency_amount = customer_order.payments.where(paymentable_type: 'Partner')&.first&.currency_amount
            if currency_amount.present?
              amount += currency_amount
            end
          end
          amount
        end

        def collected_by_sr
          amount = 0
          object[:customer_orders].each do |customer_order|
            currency_amount = customer_order.payments.where(receiver_type: 'RouteDevice')&.first&.currency_amount
            if currency_amount.present?
              amount += currency_amount
            end
          end
          amount
        end

        def unpack_return
          total_count = object[:return_customer_orders].unpacked&.count
          collected_by_sr = object[:return_customer_orders]
                              .where(
                                'return_type = ? AND return_status = ? OR return_status = ?',
                                ReturnCustomerOrder.return_types[:unpacked],
                                ReturnCustomerOrder.return_statuses[:in_transit],
                                ReturnCustomerOrder.return_statuses[:delivered_to_dh]
                              ).count
          {no_of_skus: total_count, collected_by_sr: collected_by_sr}
        end

        def pack_return
          total_order_count = object[:return_customer_orders].packed&.count
          collected_by_sr = object[:return_customer_orders]
                              .where(
                                'return_type = ? AND return_status = ? OR return_status = ?',
                                ReturnCustomerOrder.return_types[:packed],
                                ReturnCustomerOrder.return_statuses[:in_transit],
                                ReturnCustomerOrder.return_statuses[:delivered_to_dh]
                              ).count
          {no_of_orders: total_order_count, collected_by_sr: collected_by_sr}
        end

      end
    end
  end
end