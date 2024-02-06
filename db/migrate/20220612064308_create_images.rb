class CreateImages < ActiveRecord::Migration[6.0]
  def change
    create_table :banner_images do |t|
      t.integer :promo_banner_id
      t.integer :image_type, default: 0
      t.string :redirect_url, default: ''

      t.timestamps
    end
  end
end
