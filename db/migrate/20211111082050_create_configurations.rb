class CreateConfigurations < ActiveRecord::Migration[6.0]
  def change
    create_table :configurations do |t|
      t.string :name, null: false
      t.float :value, default: 0.0

      t.timestamps
    end
  end
end
