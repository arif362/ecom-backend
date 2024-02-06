class AggregatedTransactionCustomerOrder < ApplicationRecord
  belongs_to :customer_order
  belongs_to :aggregated_transaction

  enum transaction_type: { customer_payment: 0, agent_commission: 1, sub_agent_commission: 2 }
end
