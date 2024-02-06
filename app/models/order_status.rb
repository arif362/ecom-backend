class OrderStatus < ApplicationRecord
  audited
  has_many :customer_orders
  has_many :customer_order_status_changes

  # TODO: Please add in status.yml bangla fields if new order type is added
  enum order_type:
           {
             order_placed: 0,
             order_confirmed: 1,
             ready_to_shipment: 2,
             in_transit: 3,
             in_transit_partner_switch: 4,
             in_transit_delivery_switch: 5,
             delivered_to_partner: 6,
             completed: 7,
             cancelled: 8,
             on_hold: 9,
             sold_to_partner: 10,
             in_transit_reschedule: 11,
             in_transit_cancelled: 12,
             packed_cancelled: 13,
             returned_from_customer: 14,
             partially_returned: 15,
             returned_from_partner: 16,
             ready_to_ship_from_fc: 17,
             in_transit_to_dh: 18,
             cancelled_at_in_transit_to_dh: 19,
             cancelled_at_dh: 20,
             cancelled_at_in_transit_to_fc: 21,
           }

  alias_attribute :status_key, :order_type

  CUSTOMER_ORDER_TRACKING = {
    'order_order_place': 'Confirmed',
    'order_order_confirmed': 'Processed',
    'order_ready_to_shipment': 'Picked',
    'order_in_transit': 'Shipped',
    'order_completed': 'Delivered',
  }.freeze

  PICKUP_ORDER_STEPS = %w(order_placed ready_to_ship_from_fc in_transit delivered_to_partner completed cancelled).freeze
  HOME_DEL_ORDER_STEPS = %w(order_placed ready_to_ship_from_fc in_transit completed cancelled).freeze

  def self.getOrderStatus(type)
    OrderStatus.find_by(order_type: type)
  end

  def self.fetch_statuses(types)
    OrderStatus.where(order_type: types)
  end

  def self.status(status)
    case status
    when 'in_progress'
      OrderStatus.fetch_statuses(
        %w(order_placed order_confirmed ready_to_shipment in_transit
           in_transit_partner_switch in_transit_delivery_switch delivered_to_partner in_transit_reschedule),
      )
    when 'completed'
      OrderStatus.fetch_statuses(
        %w(completed returned_from_customer partially_returned),
      )
    when 'cancelled'
      OrderStatus.fetch_statuses(
        %w(cancelled in_transit_cancelled packed_cancelled returned_from_partner),
      )
    end
  end
end
