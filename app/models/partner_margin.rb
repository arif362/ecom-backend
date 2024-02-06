class PartnerMargin < ApplicationRecord
  audited
  belongs_to :customer_order
  belongs_to :partner

  def self.calculate_margin(order)
    return false unless order.partner.present?
    return 0 if order.b2b?
    return false if order.home_delivery? || order.express_delivery?
    return 0 unless order.partner.is_commission_applicable?
    return 15 if order.organic? && order.pick_up_point?

    induced_margin(order)
  end

  def self.induced_margin(order)
    if order.return_coupon?
      order.cart_total_price * 0.05
    else
      commission_able_amount = order.cart_total_price - order.total_discount_amount
      commission_able_amount.negative? ? 0 : commission_able_amount * 0.05
    end
  end

end
