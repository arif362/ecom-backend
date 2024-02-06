class AddCreatedByToCoupon < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :created_by_id, :integer
  end
end
