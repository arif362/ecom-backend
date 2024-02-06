class MonthWisePaymentHistory < ApplicationRecord
  belongs_to :warehouse, optional: true
  belongs_to :distributor, optional: true
end
