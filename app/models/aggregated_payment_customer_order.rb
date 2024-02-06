class AggregatedPaymentCustomerOrder < ApplicationRecord
  belongs_to :customer_order
  belongs_to :aggregated_payment

  enum payment_type: { sr_margin: 0, partner_margin: 1 }
end
