class ChangeDefaultColsRaCoupons < ActiveRecord::Migration[6.0]
  def change
    change_column_default :ra_coupons, :is_deleted, false
    change_column_default :ra_coupons, :is_used, false
  end
end
