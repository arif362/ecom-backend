module ShopothPartner
  module V1
    module Entities
      class ReturnCustomerOrders < Grape::Entity
        expose :return_id
        expose :order_id
        expose :customer
        expose :return_status
        expose :app_return_status
        expose :return_type
        expose :business_type
        expose :app_return_type
        expose :initiated_by
        expose :app_initiated_by

        def return_id
          object&.id
        end

        def order_id
          object&.customer_order&.id
        end

        def customer
          customer = object&.customer_order&.customer
          phone = I18n.locale == :bn ? customer&.phone.to_s.to_bn : customer&.phone
          {
            name: customer&.name,
            phone: phone,
          }
        end

        def return_status
          object&.return_status
        end

        def return_type
          object&.return_type
        end

        def business_type
          object&.customer_order&.business_type
        end

        def initiated_by
          if object.return_orderable_type == 'CustomerCareAgent'
            'Customer Care'
          else
            object.return_orderable_type || ''
          end
        end

        def app_return_status
          return_status = object&.return_status
          I18n.locale == :bn ? I18n.t("return_order_status.#{return_status}") : return_status
        end

        def app_return_type
          return_type = object&.return_type
          I18n.locale == :bn ? I18n.t("return_type.#{return_type}") : return_type
        end

        def app_initiated_by
          initiate = object.return_orderable_type || ''
          I18n.locale == :bn ? ReturnCustomerOrder::INITIATED_BY[initiate.to_sym] : ReturnCustomerOrder::EN_INITIATED_BY[initiate.to_sym]
        end
      end
    end
  end
end
