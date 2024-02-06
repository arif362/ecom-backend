module ShopothWarehouse
  module V1
    module Entities
      class BankTransactionDetails < Grape::Entity
        include ShopothWarehouse::V1::Helpers::ImageHelper

        expose :id, as: :transaction_id
        expose :warehouse_name
        expose :collection_date
        expose :amount
        expose :to_bank
        expose :from_bank
        expose :is_approved
        expose :slip
        expose :transaction_type
        expose :customer_orders
        expose :chalan_no
        expose :chalan_images
        expose :created_by

        def warehouse_name
          object.transactionable_by&.name
        end

        def collection_date
          object.created_at.to_date
        end

        def to_bank
          object.credit_bank_account&.bank_name
        end

        def from_bank
          object.debit_bank_account&.bank_name
        end

        def slip
          image_variant_path(object.image)&.dig(:product_img)
        rescue ActiveStorage::FileNotFoundError
          nil
        rescue StandardError => _error
          nil
        end

        def transaction_type
          object.transactionable_for_type == 'AggregatedTransaction' ? object.transactionable_for&.transaction_type&.titleize : ''
        end

        def customer_orders
          order_ids = object.transactionable_for&.aggregated_transaction_customer_orders&.pluck(:customer_order_id)&.compact
          orders = CustomerOrder.where(id: order_ids).includes(:payments, :aggregated_transaction_customer_orders)
          ShopothWarehouse::V1::Entities::ReconciledOrders.represent(orders)
        end

        def chalan_images
          return [] unless object.images&.present?

          image_paths_with_id(object.images)
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
