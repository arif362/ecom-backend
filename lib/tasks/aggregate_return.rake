require 'csv'

namespace :aggregate_return do
  task returned_orders: :environment do |t, args|
    returned_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:returned])
    customer_orders = CustomerOrder.where(status: returned_status)

    customer_orders.each do |co|
      next unless co.return_customer_orders.first.unpacked?
      next if co.aggregate_returns.present?

      price = co.cart_total_price
      rider = co.return_customer_orders.first.rider
      aggregate_return = co.aggregate_returns.create!(warehouse: co.warehouse,
                                                      sub_total: price,
                                                      grand_total: price,
                                                      rider: rider)

      coupons = Coupon.where(return_customer_order_id: co.return_customer_orders.ids)
      unused_coupons = coupons.where(is_used: false)
      if unused_coupons.present? || coupons.empty?
        discount = Coupon.where(id: coupons.ids - unused_coupons.ids).sum(&:discount_amount) || 0
        new_coupon = Coupon.create!(usable: co.customer,
                                    discount_amount: price - discount,
                                    aggregate_return: aggregate_return)
        unused_coupons.delete_all
        p "new_coupon created for aggr_return: #{aggregate_return.id}: #{new_coupon.id}"
      end
      aggregate_return.update_columns(refunded: true)
      co.return_customer_orders.update_all(refunded: true, aggregate_return_id: aggregate_return.id)
      p "aggregate return created: #{aggregate_return.id}, order_id: #{co.id}"
    rescue => error
      p "aggregate return failed for returned customer order: #{co.id}, reason: #{error.message}"
      next
    end
  end

  task partially_returned_orders: :environment do |t, args|
    returned_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
    customer_orders = CustomerOrder.where(status: returned_status)

    customer_orders.each do |co|
      next unless co.return_customer_orders.first.unpacked?
      next if co.aggregate_returns.present?

      return_orders = co.return_customer_orders.where.not(return_status: %i(initiated in_partner))
      next if return_orders.empty?

      s_line_item_ids = return_orders.pluck(:shopoth_line_item_id)
      price = 0
      s_line_item_ids.each_with_index { |val, index| price += ShopothLineItem.find_by(id: val).effective_unit_price}

      rider = return_orders.first.rider
      aggregate_return = co.aggregate_returns.create!(warehouse: co.warehouse,
                                                      sub_total: price,
                                                      grand_total: price,
                                                      rider: rider)
      coupons = Coupon.where(return_customer_order_id: co.return_customer_orders.ids)
      unused_coupons = coupons.where(is_used: false)
      if unused_coupons.present? || coupons.empty?
        discount = Coupon.where(id: coupons.ids - unused_coupons.ids).sum(&:discount_amount) || 0
        new_coupon = Coupon.create!(usable: co.customer,
                                    discount_amount: price - discount,
                                    aggregate_return: aggregate_return)
        unused_coupons.delete_all
        p "new_coupon created for aggr_return: #{aggregate_return.id}: #{new_coupon.id}"
      end
      aggregate_return.update_columns(refunded: true)
      return_orders.update_all(refunded: true, aggregate_return_id: aggregate_return.id)
      p "aggregate return #{aggregate_return.id}create for partially returned orders #{co.id}"
    rescue => error
      p "aggregate return failed for partially customer order: #{co.id}, reason: #{error.message}"
      next
    end
  end

  task partially_incomplete_orders: :environment do |t, args|
    returned_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
    customer_orders = CustomerOrder.where(status: returned_status).joins(:return_customer_orders).
                      where(return_customer_orders: { return_status: %i(initiated in_partner) })
    return [] if customer_orders.empty?

    customer_orders.each do |co|
      return_orders = co.return_customer_orders.where(return_status: %i(initiated in_partner))
      next if return_orders.empty?
      next unless return_orders.first.unpacked?
      next if return_orders.first.aggregate_return.present?

      s_line_item_ids = return_orders.pluck(:shopoth_line_item_id)
      price = 0
      s_line_item_ids.each_with_index { |val, index| price += ShopothLineItem.find_by(id: val).effective_unit_price}

      rider = return_orders.first.rider
      aggregate_return = co.aggregate_returns.create!(warehouse: co.warehouse,
                                                      sub_total: price,
                                                      grand_total: price,
                                                      rider: rider)
      return_orders.update_all(aggregate_return_id: aggregate_return.id)
      p "aggregate return #{aggregate_return.id} create for partially returned orders #{co.id}"
    rescue => error
      p "aggregate return failed for partially incomplete customer order: #{co.id}, reason: #{error.message}"
      next
    end
  end

  task completed_orders: :environment do |t, args|
    complete_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
    customer_orders = CustomerOrder.where(status: complete_status)

    customer_orders.each do |co|
      next unless co.return_customer_orders.present?
      next unless co.return_customer_orders.first.unpacked?
      next if co.aggregate_returns.present?

      s_line_item_ids = co.return_customer_orders.pluck(:shopoth_line_item_id)
      price = 0
      s_line_item_ids.each_with_index { |val, index| price += ShopothLineItem.find_by(id: val).effective_unit_price}
      pick_up_charge = Configuration.return_pick_up_charge(co.return_customer_orders.first.form_of_return.to_s)
      grand_total = (price - pick_up_charge).negative? ? 0 : price - pick_up_charge
      aggr_return = co.aggregate_returns.create!(warehouse: co.warehouse,
                                                 sub_total: price,
                                                 grand_total: grand_total,
                                                 pick_up_charge: pick_up_charge)
      co.return_customer_orders.update_all(aggregate_return_id: aggr_return.id)
      p "aggr return #{aggr_return.id} create for complete order: #{co.id}"
    rescue => error
      p "aggregate return failed for completed customer order: #{co.id}, reason: #{error.message}"
      next
    end
  end

  desc 'Add Distributor Id'
  task update_distributor: :environment do |t, args|
    aggregate_returns = AggregateReturn.where(distributor_id: nil)
    aggregate_returns.each do |co|
      co.update!(distributor_id: co.customer_order&.distributor_id)
    end
  end
end
