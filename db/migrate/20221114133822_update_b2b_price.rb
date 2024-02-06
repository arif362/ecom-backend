class UpdateB2bPrice < ActiveRecord::Migration[6.0]
  def change
    change_column :variants, :b2b_price, :decimal, default: 0.0
  end
end
