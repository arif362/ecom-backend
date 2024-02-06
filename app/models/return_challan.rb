class ReturnChallan < ApplicationRecord
  audited
  belongs_to :distributor
  belongs_to :warehouse
  belongs_to :created_by, foreign_key: :created_by_id, class_name: 'Staff'
  has_many :return_challan_line_items, dependent: :destroy
  has_many :customer_orders,  through: :return_challan_line_items, source: :orderable, source_type: "CustomerOrder"
  has_many :return_customer_orders,  through: :return_challan_line_items, source: :orderable, source_type: "ReturnCustomerOrder"

  validates :return_challan_line_items, presence: true
  validate :validate_destroy, on: :destroy

  enum status: {initiated: 0, in_transit_to_fc: 1, partially_received: 2, completed: 3}

  default_scope { where(is_deleted: false) }

  accepts_nested_attributes_for :return_challan_line_items,
                                reject_if: :all_blank,
                                allow_destroy: true,
                                update_only: true

  def dispatch!(current_staff)
    fail StandardError, 'only initiated status can perform dispatch' unless status == 'initiated'
    ActiveRecord::Base.transaction do
      self.update!(status: :in_transit_to_fc)
      customer_orders.each do |co|
        co.update!(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled_at_in_transit_to_fc]), changed_by: current_staff)
        co.update_wv_and_stock_change
      end
      return_customer_orders.each do |rco|
        rco.update!(return_status: :in_transit_to_fc, changeable: current_staff)
        rco.update_inventory_and_stock_changes('return_in_transit_to_fc_quantity', 'return_in_dh_quantity')
      end
    end
  end

  def receive!(cancelled_order_ids, returned_order_ids , current_staff)
    cancelled_order_ids = cancelled_order_ids.reject(&:blank?)
    returned_order_ids = returned_order_ids.reject(&:blank?)

    if cancelled_order_ids.length == 0 and returned_order_ids.length == 0
      fail StandardError, 'requested receive id list is empty'
    end

    fail StandardError, 'only in_transit_to_fc and partially_received status can perform receive' unless %w[in_transit_to_fc partially_received].include?(status)
    receive_cancelled_orders = customer_orders.where(id: cancelled_order_ids)
    receive_returned_orders = return_customer_orders.where(id: returned_order_ids)

    unless receive_cancelled_orders.count == cancelled_order_ids.length or receive_returned_orders.count == returned_order_ids.length
      fail StandardError, 'all order ids are not present into given return challan'
    end

    ActiveRecord::Base.transaction do
      receive_cancelled_orders.each do |co|
        co.update!(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:packed_cancelled]), changed_by: current_staff)
        co.return_challan_line_item.update!(status: :received_by_fc)
        co.update_wv_and_stock_change
      end

      receive_returned_orders.each do |rco|
        rco.update!(return_status: :qc_pending, changeable: current_staff)
        rco.return_challan_line_item.update!(status: :received_by_fc)
        rco.update_inventory_and_stock_changes('return_qc_pending_quantity','return_in_transit_to_fc_quantity')
      end

      number_of_received_item = return_challan_line_items.where(status: :received_by_fc).count
      status_changed_to = :completed
      status_changed_to = :partially_received unless number_of_received_item == return_challan_line_items.count
      self.update!(status: status_changed_to)
    end
  end

  private
  def validate_destroy
    errors.add(:status, "only initiated can perform destroy") unless self.status == :initiated
  end
end
