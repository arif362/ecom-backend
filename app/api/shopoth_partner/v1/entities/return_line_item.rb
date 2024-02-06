module ShopothPartner
  module V1
    module Entities
      class ReturnLineItem < Grape::Entity
        expose :id, as: :return_id
        expose :return_date
        expose :order_id
        expose :customer
        expose :return_status
        expose :app_return_status
        expose :reason
        expose :app_reason
        expose :description
        expose :quantity
        expose :business_type
        expose :items, using: ShopothPartner::V1::Entities::ShopothLineItemList

        def business_type
          object&.customer_order&.business_type
        end
        def order_id
          object&.customer_order&.id
        end

        def return_date
          object&.created_at
        end

        def return_status
          object&.return_status
        end

        def app_return_status
          return_status = object&.return_status
          I18n.locale == :bn ? I18n.t("return_order_status.#{return_status}") : return_status
        end

        def app_reason
          reason = object.reason
          I18n.locale == :bn ? I18n.t("return_reason.#{reason}") : reason
        end

        def customer
          customer = object&.customer_order&.customer
          phone = I18n.locale == :bn ? customer&.phone.to_s.to_bn : customer&.phone
          {
            name: customer&.name,
            phone: phone,
          }
        end

        def items
          line_items = []
          if object&.return_type == 'packed'
            object&.customer_order&.shopoth_line_items&.each do |item|
              line_items << item
            end
          else
            line_items << object&.shopoth_line_item
          end
          line_items
        end
      end
    end
  end
end
