class AddDefaultValueToConsumerDiscount < ActiveRecord::Migration[6.0]
  def up
    change_column_default :variants, :consumer_discount, 0.0

    Variant.find_each do |variant|
      variant.update consumer_discount: 0.0 if variant.consumer_discount.nil?
    end
  end

  def down; end
end
