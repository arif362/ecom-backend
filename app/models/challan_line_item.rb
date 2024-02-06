class ChallanLineItem < ApplicationRecord
  belongs_to :challan
  belongs_to :customer_order
  belongs_to :received_by, foreign_key: :received_by_id, class_name: 'Staff', optional: true

  validates_uniqueness_of :customer_order_id
  validate :validate_order_status, on: :create
  validate :validate_remove_order, on: :destroy

  enum status: {pending: 0, received_by_dh: 1}

  private
  def validate_order_status
    errors.add(:customer_order, "only ready_to_ship_from_fc can include in challan") unless customer_order&.status.ready_to_ship_from_fc?
  end

  def validate_remove_order
    errors.add(:customer_order, "can remove only from initiated challan") unless challan.initiated?
  end
end
