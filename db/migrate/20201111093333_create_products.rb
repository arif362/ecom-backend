class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      t.float :quantity
      t.datetime :availability
      t.string :image
      t.string :promotional
      t.string :discount

      t.timestamps
    end
  end
end
