class CreateBoxLineItems < ActiveRecord::Migration[6.0]
  def change
    create_table :box_line_items do |t|
      t.references :line_item, foreign_key: true, null: false
      t.references :box, foreign_key: true, null: false
      t.timestamps
    end
  end
end
