class AggregatedTransaction < ApplicationRecord
  has_many :aggregated_transaction_customer_orders, dependent: :destroy
  has_one :bank_transaction, as: :transactionable_for
  validate :validate_month

  enum transaction_type: { customer_payment: 0, agent_commission: 1, sub_agent_commission: 2 }
  enum month: {
    unselected: 0,
    january: 1,
    february: 2,
    march: 3,
    april: 4,
    may: 5,
    june: 6,
    july: 7,
    august: 8,
    september: 9,
    october: 10,
    november: 11,
    december: 12,
  }

  def validate_month
    c_day = Date.today.strftime('%d').to_i
    c_month = Date.today.strftime('%m').to_i
    c_year = Date.today.strftime('%Y').to_i

    if AggregatedTransaction.months[month] == c_month &&
       year == c_year &&
       (transaction_type == 'agent_commission' || transaction_type == 'sub_agent_commission')
      errors.add(:month, ", Payment can't be created for this month")
    elsif AggregatedTransaction.months[month] == (c_month - 1) &&
          c_day <= 7 &&
          (transaction_type == 'agent_commission' || transaction_type == 'sub_agent_commission')
      errors.add(:month, ', You can pay for this month after date 7')
    end
  end
end
