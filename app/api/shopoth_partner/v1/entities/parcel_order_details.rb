module ShopothPartner
  module V1
    module Entities
      class ParcelOrderDetails < Grape::Entity
        expose :id, as: :order_id
        expose :customer
        expose :total_price, as: :amount
        expose :order_type
        expose :business_type
        expose :app_order_type
        expose :status
        expose :app_status
        expose :order_place_at
        expose :expected_delivery_time
        expose :expire_date
        expose :expected_delivery_time_exceed

        def order_place_at
          object.created_at.to_datetime.strftime('%Q')
        end

        def expected_delivery_time
          due_date_time = object.created_at + 72.hours
          due_date_time.to_datetime.strftime('%Q')
        end

        def expire_date
          delivered_to_partner_date = object.delivered_to_partner_order_status_date
          if delivered_to_partner_date.present?
            if object.organic?
              extand_time = delivered_to_partner_date + 9.days
              extand_time.to_datetime.strftime('%Q')
            elsif object.induced?
              extand_time = delivered_to_partner_date + 4.days
              extand_time.to_datetime.strftime('%Q')
            end
          end
        end

        def expected_delivery_time_exceed
          current_time = DateTime.now.to_f
          order_place_at = object.created_at.to_f
          (current_time - order_place_at) >= 72.hours.to_f
        end

        def customer
          phone = I18n.locale == :bn ? object&.customer&.phone.to_s.to_bn : object&.customer&.phone
          {
            customer_id: object&.customer_id,
            name: object&.customer&.name,
            phone: phone,
          }
        end

        def status
          object&.status&.order_type
        end

        def app_status
          status = object&.status&.order_type
          I18n.locale == :bn ? I18n.t("order_status.#{status}") : status
        end

        def app_order_type
          type = object.order_type
          I18n.locale == :bn ? I18n.t("order_type.#{type}") : type
        end
      end
    end
  end
end
