class CreatePromoBanners < ActiveRecord::Migration[6.0]
  def change
    create_table :promo_banners do |t|
      t.string :title
      t.integer :layout

      t.timestamps
    end
  end
end
