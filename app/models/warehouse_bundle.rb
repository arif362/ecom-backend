class WarehouseBundle < ApplicationRecord
  belongs_to :bundle
  belongs_to :warehouse
  has_many :line_items, as: :itemable

  def add_line_item(variant, quantity, location_id)
    line_items.create!(
      variant: variant, quantity: quantity, received_quantity: quantity, qc_status: true, qc_passed: quantity,
      price: variant.price_distribution, send_quantity: quantity, reconcilation_status: 'closed',
      location_id: location_id
    )
  end
end
