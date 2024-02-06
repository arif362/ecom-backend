class CreateBrandFollowing < ActiveRecord::Migration[6.0]
  def change
    create_table :brand_followings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :brand, null: false, foreign_key: true
    end
  end
end
