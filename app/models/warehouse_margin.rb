class WarehouseMargin < ApplicationRecord
  belongs_to :customer_order
  belongs_to :warehouse

  def self.create_commission(warehouse, cust_order)
    amount = WarehouseMargin.generate_amount(warehouse, cust_order)
    WarehouseMargin.find_or_create_by!(warehouse: warehouse,
                                       customer_order: cust_order,
                                       amount: amount,
                                       is_commissionable: warehouse.is_commission_applicable)
  end

  def self.generate_amount(warehouse, cust_order)
    return 0 unless warehouse.is_commission_applicable?

    if cust_order.return_coupon?
      cust_order.cart_total_price * 0.015
    else
      commissionable_amount = cust_order.cart_total_price - cust_order.total_discount_amount
      commissionable_amount.negative? ? 0 : commissionable_amount * 0.015
    end
  end

  def deduct_margin(item)
    return 0 if amount <= 0

    price = item.effective_unit_price
    deducted_amount = (amount - (price * 0.015)).negative? ? 0 : amount - (price * 0.015)
    update!(amount: deducted_amount)
  end
end
