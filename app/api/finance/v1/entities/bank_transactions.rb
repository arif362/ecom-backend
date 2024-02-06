module Finance
  module V1
    module Entities
      class BankTransactions < Grape::Entity
        expose :id
        expose :warehouse_name
        expose :collection_date
        expose :amount
        expose :to_bank
        expose :from_bank
        expose :order_count
        expose :is_approved
        expose :chalan_no

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

        def order_count
          object.transactionable_for&.aggregated_transaction_customer_orders&.size
        end
      end
    end
  end
end
