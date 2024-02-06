module Finance
  module V1
    module Entities
      class AgentBankTransaction < Grape::Entity
        expose :id, as: :transaction_id
        expose :warehouse_name
        expose :collection_date
        expose :amount
        expose :to_bank
        expose :from_bank
        expose :order_count
        expose :is_approved
        expose :chalan_no
        expose :transaction_type

        def warehouse_name
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

        def order_count
          object.transactionable_for&.aggregated_transaction_customer_orders&.size
        end

        def transaction_type
          object.transactionable_for_type == 'AggregatedTransaction' ? object.transactionable_for&.transaction_type : ''
        end
      end
    end
  end
end
