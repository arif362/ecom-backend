class FailedQc < ApplicationRecord
  audited
  belongs_to :failable, polymorphic: true, optional: true
  belongs_to :warehouse
  belongs_to :variant, optional: true
  belongs_to :line_item, optional: true
  has_many :stock_changes, as: :stock_changeable

  enum qc_failed_type: { quality_failed: 0, quantity_failed: 1 }

  after_update :update_is_settled

  attr_accessor :changed_by

  SETTLEMENT_ACTION = {
    received: 'received',
    closed_forcefully: 'closed'
  }.freeze

  def is_quantity_failed?
    qc_failed_type == FailedQc.qc_failed_types[:quantity_failed]
  end

  def is_quality_failed?
    qc_failed_type == FailedQc.qc_failed_types[:quality_failed]
  end

  def open_quantity
    quantity - received_quantity - closed_quantity
  end

  def line_item
    failable.line_items.find_by(variant_id: variant_id)
  end

  def self.fetch_orders(order_type, warehouse_id)
    where(failable_type: order_type, warehouse_id: warehouse_id).order(created_at: :desc).includes(:variant)
  end

  private

  def update_is_settled
    return true if quantity > (received_quantity + closed_quantity)

    update_column(:is_settled, true)
    line_item.update_reconcilation_status(changed_by) if line_item_id.present?
  end
end
