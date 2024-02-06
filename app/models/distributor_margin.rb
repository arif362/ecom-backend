class DistributorMargin < ApplicationRecord
  audited
  belongs_to :distributor
  belongs_to :customer_order

  ########################################
  ########### Instance methods ###########
  ########################################
  def deduct(item)
    return 0 unless amount.positive?

    price = item.effective_unit_price * 0.015
    deducted_amount = (amount - price).positive? ? (amount - price) : 0
    update!(amount: deducted_amount)
  end

  #######################################
  ############ Class methods ############
  #######################################
  def self.create_commission(order)
    distributor = order.distributor
    amount = DistributorMargin.generate_amount(distributor, order)
    dh_margin = DistributorMargin.find_or_create_by!(distributor: order.distributor, customer_order: order)
    dh_margin.update_columns(amount: amount,
                             is_commissionable: distributor.is_commission_applicable)
  end

  def self.generate_amount(distributor, cust_order)
    return 0 unless distributor.is_commission_applicable

    if cust_order.return_coupon?
      cust_order.cart_total_price * 0.015
    else
      commissionable_amount = cust_order.cart_total_price - cust_order.total_discount_amount
      commissionable_amount.negative? ? 0 : commissionable_amount * 0.015
    end
  end
end
