module ShopothWarehouse
  module V1
    module Entities
      class Partners < Grape::Entity
        include ShopothWarehouse::V1::Helpers::ImageHelper

        expose :id
        expose :route
        expose :name
        expose :phone
        expose :image
        expose :email
        expose :password_presence
        expose :status
        expose :schedule
        expose :tsa_id
        expose :retailer_code
        expose :partner_code
        expose :region
        expose :area
        expose :territory
        expose :point
        expose :owner_name
        expose :cluster_name
        expose :sub_channel
        expose :bn_name
        expose :latitude
        expose :longitude
        expose :work_days
        expose :slug
        expose :is_commission_applicable
        expose :bkash_number
        # expose :wallet_balance
        expose :due_payment
        expose :addresses do |partner, _options|
          ShopothWarehouse::V1::Entities::Addresses.represent(partner.address)
        end
        expose :meta_info
        expose :distributor_name
        expose :created_by
        expose :business_type
        # def wallet_balance
        #   object.create_wallet(currency_amount: 0.0, currency_type: 'Tk.') if object.wallet.nil?
        #   object&.wallet&.currency_amount
        # end

        def due_payment
          status_ids = OrderStatus.fetch_statuses(%w(delivered_to_partner completed)).ids
          orders = object.customer_orders.where(order_status_id: status_ids).where.not(pay_status: 'partner_paid')
          (orders.sum(:total_price) - orders.joins(:payments).where(payments: { status: :successful, paymentable_type: 'Partner' })&.sum(:currency_amount)).ceil
        end

        def get_commission(order)
          commission = 0
          order.shopoth_line_items.each do |line_item|
            variant = line_item.variant
            price_consumer = variant.price_consumer || 0
            price_retailer = variant.price_retailer || 0
            commission += (price_consumer - price_retailer).abs * line_item.quantity
          end
          commission
        end

        def password_presence
          object.encrypted_password.present?
        end

        def image
          image_path(object&.image)
        rescue ActiveStorage::FileNotFoundError
          nil
        rescue StandardError => _error
          nil
        end

        def meta_info
          ShopothWarehouse::V1::Entities::MetaData.represent(object.meta_datum)
        end

        def distributor_name
          object&.route&.distributor&.name
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
