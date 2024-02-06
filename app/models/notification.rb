class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :user_notifiable, polymorphic: true, optional: true

  def self.get_notification_message(order)
    order_id = order.id
    case order.status.order_type
    when 'order_placed'
      "Your order (#{order_id}) is placed!"
    when 'order_confirmed'
      "Your order (#{order_id}) is confirmed!"
    when 'ready_to_shipment'
      "Your order (#{order_id}) is being processed!"
    when 'in_transit'
      "Your order (#{order_id}) is shipped!"
    when 'completed'
      "Your order (#{order_id}) is delivered!"
    when 'cancelled'
      "Your order (#{order_id}) is cancelled!"
    when 'delivered_to_partner'
      "Your order (#{order_id}) is about to delivered!"
    when 'in_transit_partner_switch'
      "Your order (#{order_id}) is about to delivered!"
    else
      ''
    end
  end
end
