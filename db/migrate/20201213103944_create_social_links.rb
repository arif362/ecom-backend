class CreateSocialLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :social_links do |t|
      t.string :name
      t.string :url
      t.integer :store_info_id
      t.timestamps
    end
  end
end
