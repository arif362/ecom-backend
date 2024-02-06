module ShopothWarehouse
  module V1
    module Entities
      class DeliveryList < Grape::Entity
        expose :id, as: :order_id
        expose :order_status
        expose :order_type
        expose :business_type
        expose :shop_name
        expose :phone
        expose :amount
        expose :payment_type
        expose :history_due_date_time
        expose :deleverd_to_partner_status_date_time
        expose :order_place_at
        expose :expected_delivery_time
        expose :expire_date
        expose :expected_delivery_time_exceed
        expose :business_type

        def order_place_at
          object.created_at.to_datetime.strftime('%Q')
        end

        def expected_delivery_time
          due_date_time = object.created_at + 72.hours
          due_date_time.to_datetime.strftime('%Q')
        end

        def expire_date
          due_date_time = object.created_at + 72.hours
          if object.organic?
            extand_time = due_date_time + 9.days
            extand_time.to_datetime.strftime('%Q')
          elsif object.induced?
            extand_time = due_date_time + 4.days
            extand_time.to_datetime.strftime('%Q')
          end
        end


        def history_due_date_time
          due_time = object.created_at + 72.hours
          due_time.strftime("#{due_time.day.ordinalize} %B, %I:%M %p")
        end

        def deleverd_to_partner_status_date_time
          status = OrderStatus.getOrderStatus(OrderStatus.order_types[:delivered_to_partner])
          status_datetime = object&.customer_order_status_changes&.where(order_status_id: status.id)&.last&.created_at
          status_datetime&.strftime("#{status_datetime.day.ordinalize} %B, %I:%M %p")
        end

        def expected_delivery_time_exceed
          current_time = DateTime.now.to_f
          order_place_at = object.created_at.to_f
          if (current_time - order_place_at) >= 72.hours.to_f
            true
          else
            false
          end
        end

        def order_status
          object.status.order_type
        end

        def shop_name
          object.partner&.name
        end

        def phone
          object.partner&.phone
        end

        def amount
          partner_commission = 0
          # partner_commission = object.induced? ? object.partner_commission : 0
          object.total_price - partner_commission
        end

        def payment_type
          payment_type = 'online_payment'
          payment_type = 'cash_on_delivery' if object.cash_on_delivery?
          payment_type
        end
      end
    end
  end
end
