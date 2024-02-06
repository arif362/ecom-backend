namespace :fix_grand_total do
  task customer_order: :environment do |t, args|
    customer_order = CustomerOrder.find(23278)
    cart_sub_total = customer_order.shopoth_line_items_total_price
    discount = customer_order.total_discount_amount
    current_grand_total = customer_order.total_price
    total_price = cart_sub_total - discount + customer_order.shipping_charge
    customer_order.update_columns(cart_total_price: cart_sub_total,
                                  total_price: total_price)

    # Warehouse margin
    amount = (cart_sub_total - discount) * 0.015
    amount = amount.negative? ? 0 : amount
    customer_order.distributor_margin.update_columns(amount: amount)
    p 'Warehouse margin is update'

    # Partner margin
    partner_margin = customer_order.partner_margin
    margin_amount = if customer_order.induced?
                      (cart_sub_total - discount) * 0.05
                    else
                      15
                    end
    partner_margin.update_columns(margin_amount: margin_amount)
    p 'Partner margin is update'

    # Bank transaction and aggregate transaction
    due_amount = total_price - current_grand_total
    aggr_trans_cus_ord = AggregatedTransactionCustomerOrder.find_by(customer_order_id: customer_order.id)
    aggr_trans_cus_ord.update_columns(amount: aggr_trans_cus_ord.amount + due_amount)
    bank_transaction = aggr_trans_cus_ord.aggregated_transaction.bank_transaction
    bank_transaction.update_columns(amount: bank_transaction.amount + due_amount)
    p 'bank and aggregate transaction update'

    # stock change update
    order_place_stock = customer_order.stock_changes.order_placed.first
    order_place_stock&.update_columns(available_quantity: (order_place_stock&.available_quantity || 0) - 1,
                                      booked_quantity: (order_place_stock&.available_quantity || 0) + 1,
                                      quantity: 13,
                                      available_quantity_change: -13,
                                      booked_quantity_change: 13)
    p 'stock change update'

    # warehouse variant available quantity update, this may produce negative stock because
    # <WarehouseVariant id: 3669, warehouse_id: 6, variant_id: 1861, booked_quantity: 2,
    # available_quantity: 0, packed_quantity: 0, in_transit_quantity: 7, in_partner_quantity: 10,
    # blocked_quantity: 100, bundle_quantity: 0>
    wv = order_place_stock&.warehouse_variant
    wv&.update_columns(available_quantity: (wv&.available_quantity || 0) - 1)
    p 'wv available qty update'
  rescue => error
    p "Unable to update #{error.message}"
  end
end
