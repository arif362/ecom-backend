module ShopothPartner
  module V1
    module Entities
      class PaymentPendingOrderDetails < Grape::Entity
        expose :id, as: :order_id
        expose :customer
        expose :amount
        expose :order_type
        expose :business_type
        expose :app_order_type
        expose :pay_type, as: :payment_type
        expose :app_pay_type
        expose :pay_status
        expose :app_pay_status
        expose :status
        expose :app_status
        expose :wallet_payment

        def customer
          phone = I18n.locale == :bn ? object&.customer&.phone.to_s.to_bn : object&.customer&.phone
          {
            name: object&.customer&.name,
            phone: phone,
          }
        end

        def status
          object&.status&.order_type
        end

        def wallet_payment
          object&.payments&.where(status: :successful, form_of_payment: :wallet)&.sum(:currency_amount)
        end

        def amount
          partner_commission = 0
          # partner_commission = object.induced? ? object.partner_commission : 0
          object.total_price - partner_commission
        end

        def app_status
          status = object&.status&.order_type
          I18n.locale == :bn ? I18n.t("order_status.#{status}") : status
        end

        def app_order_type
          type = object.order_type
          I18n.locale == :bn ? I18n.t("order_type.#{type}") : type
        end

        def app_pay_type
          pay_type = object.pay_type
          I18n.locale == :bn ? I18n.t("pay_type.#{pay_type}") : pay_type
        end

        def app_pay_status
          pay_status = object.pay_status
          I18n.locale == :bn ? I18n.t("pay_status.#{pay_status}") : pay_status
        end
      end
    end
  end
end
