class ReturnChallanLineItem < ApplicationRecord
  belongs_to :return_challan
  belongs_to :orderable, polymorphic: true
  belongs_to :received_by, foreign_key: :received_by_id, class_name: 'Staff', optional: true

  validates_uniqueness_of :orderable_id, scope: :orderable_type, case_sensitive: false
  validate :validate_order_status, on: :create
  validate :validate_remove_order, on: :destroy

  enum status: {pending: 0, received_by_fc: 1}

  private
  def validate_order_status
    errors.add(:customer_order, "only cancelled can include in return_challan") if orderable_type == 'CustomerOrder' and !orderable&.status.cancelled_at_dh?
    errors.add(:return_customer_order, "only ready_to_ship_from_fc can include in return_challan") if orderable_type == 'ReturnCustomerOrder' and !orderable&.delivered_to_dh?
  end

  def validate_remove_order
    errors.add(:customer_order, "can remove only from initiated return_challan") unless return_challan.initiated?
  end
end
