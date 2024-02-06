class CreateFavoriteStore < ActiveRecord::Migration[6.0]
  def change
    create_table :favorite_stores do |t|
      t.references :user, null: false, foreign_key: true
      t.references :partner, null: false, foreign_key: true
    end
  end
end
