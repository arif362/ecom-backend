class CreateStaticPages < ActiveRecord::Migration[6.0]
  def change
    create_table :static_pages do |t|
      t.string :title, null: false
      t.text :body
      t.string :slug, index: true
      t.integer :is_active, default: 0
      t.boolean :show_in_footer, default: false
      t.integer :position

      t.timestamps
    end
  end
end
