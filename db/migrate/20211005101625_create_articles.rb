class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.references :help_topic, foreign_key: true, null: false
      t.string :title
      t.text :body
      t.boolean :public_visibility, default: true
      t.timestamps
    end
  end
end
