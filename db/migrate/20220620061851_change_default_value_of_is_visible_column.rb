class ChangeDefaultValueOfIsVisibleColumn < ActiveRecord::Migration[6.0]
  def change
    change_column_default :promo_banners, :is_visible, false
  end
end
