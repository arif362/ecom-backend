module ShopothWarehouse
  module V1
    module Entities
      class BankTransactions < Grape::Entity
        expose :id
        expose :warehouse_name
        expose :amount
        expose :chalan_no
        expose :to_bank
        expose :from_bank
        expose :is_approved
        expose :order_count
        expose :collection_date

        def warehouse_name
          object.transactionable_by&.name
        end

        def to_bank
          object.credit_bank_account&.bank_name
        end

        def from_bank
          object.debit_bank_account&.bank_name
        end

        def order_count
          object.transactionable_for&.aggregated_transaction_customer_orders&.size
        end

        def collection_date
          object.created_at.to_date
        end
      end
    end
  end
end
