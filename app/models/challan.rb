class Challan < ApplicationRecord
  audited
  belongs_to :distributor
  belongs_to :warehouse
  belongs_to :created_by, foreign_key: :created_by_id, class_name: 'Staff'
  has_many :challan_line_items, dependent: :destroy
  has_many :customer_orders, through: :challan_line_items

  validates :challan_line_items, presence: true
  validate :validate_destroy, on: :destroy

  enum status: { initiated: 0, in_transit_to_dh: 1, partially_received: 2, completed: 3 }

  default_scope { where(is_deleted: false) }

  accepts_nested_attributes_for :challan_line_items,
                                reject_if: :all_blank,
                                allow_destroy: true,
                                update_only: true

  def dispatch!(current_staff)
    fail StandardError, 'only initiated can perform dispatch' unless status == 'initiated'
    ActiveRecord::Base.transaction do
      self.update!(status: :in_transit_to_dh)
      fail_customer_orders = customer_orders.where.not(order_status_id: OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_ship_from_fc]).id)
      fail StandardError, "need to remove this orders: #{fail_customer_orders.map(&:id)}" unless fail_customer_orders.count.zero?
      customer_orders.each do |co|
        co.update!(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit_to_dh]), changed_by: current_staff)
        co.update_wv_and_stock_change
      end
    end
  end

  def receive!(order_ids, current_staff)
    fail StandardError, 'only in_transit_to_dh and partially_received status can perform receive' unless %w[in_transit_to_dh partially_received].include?(status)
    receive_orders = customer_orders.where(id: order_ids)
    fail StandardError, 'all order ids are not present into given challan' unless receive_orders.count == order_ids.length

    ActiveRecord::Base.transaction do
      receive_orders.each do |co|
        fail StandardError, "status mismatched for customer order: #{co.id}" unless co.status.in_transit_to_dh? or co.status.cancelled_at_in_transit_to_dh?
        co_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_shipment])
        co_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled_at_dh]) unless co.status.in_transit_to_dh?
        co.update!(status: co_status, changed_by: current_staff)
        co.challan_line_item.update!(status: :received_by_dh)
        co.update_wv_and_stock_change
      end
      number_of_received_item = challan_line_items.where(status: :received_by_dh).count
      status_changed_to = :completed
      status_changed_to = :partially_received unless number_of_received_item == challan_line_items.count
      self.update!(status: status_changed_to)
      received_customer_orders = challan_line_items.where(status: :received_by_dh)
    end
  end

  private
  def validate_destroy
    errors.add(:status, "only initiated can perform destroy") unless self.status == :initiated
  end
end
