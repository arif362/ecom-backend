class CreateNewsLetters < ActiveRecord::Migration[6.0]
  def change
    create_table :news_letters do |t|
      t.string :email, null: false
      t.boolean :is_active, default: true

      t.timestamps
    end
  end
end
