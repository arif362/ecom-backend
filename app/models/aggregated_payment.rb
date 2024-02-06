class AggregatedPayment < ApplicationRecord
  has_many :aggregated_payment_customer_orders, dependent: :destroy
  has_one :payment
  belongs_to :received_by, polymorphic: true

  validate :validate_month

  enum payment_type: { sr_margin: 0, partner_margin: 1 }
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
  enum partner_schedule: { sat_mon_wed: 0, sun_tues_thurs: 1, sat_sun_mon_tues_wed_thurs: 2 }

  def validate_month
    c_day = Date.today.strftime('%d').to_i
    c_month = Date.today.strftime('%m').to_i
    c_year = Date.today.strftime('%Y').to_i
    if AggregatedPayment.months[self.month] == c_month && self.year == c_year
      self.errors.add(:month, ", Payment can't be created for this month")
    elsif AggregatedPayment.months[self.month] == (c_month - 1) && c_day <= 7
      self.errors.add(:month, ', You can pay for this month after date 7')
    end
  end
end
