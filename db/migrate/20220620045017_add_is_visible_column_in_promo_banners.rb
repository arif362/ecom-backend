class AddIsVisibleColumnInPromoBanners < ActiveRecord::Migration[6.0]
  def change
    add_column :promo_banners, :is_visible, :boolean, default: true
  end
end
