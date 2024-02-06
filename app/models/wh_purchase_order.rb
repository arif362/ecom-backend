class WhPurchaseOrder < ApplicationRecord
  audited
  has_many :line_items, as: :itemable
  # has_many :payment
  # has_one :address
  belongs_to :supplier
  belongs_to :staff, optional: true
  has_many :stock_changes, as: :stock_changeable
  has_many :failed_qcs, as: :failable
  has_many :purchase_order_status, as: :orderable, class_name: 'PurchaseOrderStatus'
  has_many :bank_transactions, as: :transactionable_for

  attr_accessor :changed_by
  
  after_update :change_purchase_order_status, if: :saved_change_to_order_status?

  validates :supplier_id, :quantity, presence: true
  validates :total_price, presence: true
  validates :unique_id, uniqueness: true
  enum order_status:
         {
           order_placed: 0,
           order_confirmed: 1,
           ready_to_shipment: 2,
           in_transit: 3,
           received_to_cwh: 4,
           completed: 5,
           reconcilation_pending: 6,
         }

  def change_purchase_order_status
    StatusChangedHistory::CreatePurchaseOrderStatus.call(order: self , order_status: order_status, changed_by: changed_by)
  end

  def update_reconcilation_status(changed_by)
    return unless reconcilation_pending?

    self.changed_by = changed_by
    completed! unless failed_qcs.where(is_settled: false).present?
  end
end
