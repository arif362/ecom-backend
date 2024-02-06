module ShopothWarehouse
  module V1
    module Entities
      class PartnerPayments < Grape::Entity
        expose :id, as: :order_id
        expose :pay_status, as: :payment_status
        expose :order_type
        expose :shop_name
        expose :phone
        expose :completed_at, as: :delivery_date
        expose :total_price, as: :amount
        # expose :wallet_payment
        expose :extendable_days
        expose :prepaid
        expose :business_type

        def business_type
          order&.business_type
        end

        def shop_name
          order&.partner&.name
        end

        def phone
          order&.partner&.phone
        end

        def wallet_payment
          order&.payments&.where(status: :successful, form_of_payment: :wallet)&.sum(:currency_amount)
        end

        def order
          @order ||= CustomerOrder.find(object[:id])
        end

        def prepaid
          order.payments.successful.where.not(form_of_payment: :cash).sum(:currency_amount) >= order.total_price
        end
      end
    end
  end
end
