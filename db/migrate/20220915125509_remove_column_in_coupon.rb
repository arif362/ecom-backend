class RemoveColumnInCoupon < ActiveRecord::Migration[6.0]
  def change
    rename_column :coupons, :is_multiple_used, :number_of_uses
  end
end
