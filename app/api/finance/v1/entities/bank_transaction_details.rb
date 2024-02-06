module Finance
  module V1
    module Entities
      class BankTransactionDetails < Grape::Entity
        include Finance::V1::Helpers::ImageHelpers

        expose :id
        expose :from_warehouse
        expose :to_warehouse
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

        def from_warehouse
          object.transactionable_by&.name
        end

        def to_warehouse
          object.transactionable_to&.name
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
          image_variant_path(object&.image)&.dig(:product_img)
        rescue ActiveStorage::FileNotFoundError
          nil
        rescue StandardError => _error
          nil
        end

        def transaction_type
          object.transactionable_for_type == 'AggregatedTransaction' ? object.transactionable_for&.transaction_type : ''
        end

        def customer_orders
          order_ids = object.transactionable_for&.aggregated_transaction_customer_orders&.pluck(:customer_order_id)&.compact
          orders = CustomerOrder.where(id: order_ids).includes(:payments, :aggregated_transaction_customer_orders)
          ShopothWarehouse::V1::Entities::ReconciledOrders.represent(orders)
        end

        def chalan_images
          return [] unless object&.images&.present?

          image_paths_with_id(object.images)
        end
      end
    end
  end
end
