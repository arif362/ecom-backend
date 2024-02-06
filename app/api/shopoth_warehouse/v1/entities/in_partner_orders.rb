module ShopothWarehouse
  module V1
    module Entities
      class InPartnerOrders < Grape::Entity
        expose :id, as: :order_id
        expose :order_status
        expose :order_type
        expose :shop_name
        expose :partner_id
        expose :partner_phone
        expose :total_price, as: :amount
        expose :expire_date
        expose :expected_delivery_time_exceed
        expose :prepaid
        expose :business_type

        def order_status
          object.status.order_type.humanize
        end

        def shop_name
          object&.partner&.name
        end

        def partner_phone
          object&.partner&.phone
        end

        def expire_date
          delivered_to_partner_date = object.delivered_to_partner_order_status_date
          if delivered_to_partner_date.present?
            if object.organic?
              extend_time = delivered_to_partner_date + 9.days
              extend_time.to_datetime.strftime('%Q')
            elsif object.induced?
              extend_time = delivered_to_partner_date + 4.days
              extend_time.to_datetime.strftime('%Q')
            end
          end
        end

        def expected_delivery_time_exceed
          current_time = DateTime.now.to_f
          order_place_at = object.created_at.to_f
          (current_time - order_place_at) >= 72.hours.to_f
        end

        def prepaid
          object.payments.successful.where.not(form_of_payment: :cash).sum(:currency_amount) >= object.total_price
        end
      end
    end
  end
end
