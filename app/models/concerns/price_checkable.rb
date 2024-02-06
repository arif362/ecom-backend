module PriceCheckable
  extend ActiveSupport::Concern

  included do
    # TODO: Need to add this method before creating order on order place API.
    def item_price_check(domain, warehouse, user)
      shopoth_line_items.each do |item|
        variant = item.variant
        next if item.effective_unit_price == variant.customer_effective_price

        sub_total = variant.customer_effective_price * item.quantity
        total_price = variant.price_consumer * item.quantity
        item.update_columns(price: variant.price_consumer, sub_total: sub_total,
                            discount_amount: total_price - sub_total)
        update_cart_attr(domain, warehouse, user)
      end
    end
  end
end
