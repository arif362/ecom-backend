class DeliveryPreference < ApplicationRecord
  ###############
  # Association
  ###############
  belongs_to :user
  belongs_to :partner, optional: :true
  has_one :address, as: :addressable

  ###############
  # Enumerable
  ###############
  enum pay_type: { online_payment: 0, cash_on_delivery: 1 }
  enum shipping_type: { home_delivery: 0, express_delivery: 1, pick_up_point: 2 }

  validates :partner_id, presence: true, if: :pick_up_point?
end
