class CreateRider < ActiveRecord::Migration[6.0]
  def change
    create_table :riders do |t|
      t.string :name, default: "", null: false
      t.string :phone, default: "", null: false
      t.string :email, default: "", null: false
      t.string :password_hash, default: "", null: false
      t.references :warehouse, null: false, foreign_key: true
    end
  end
end
