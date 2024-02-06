class CreateFeedbacks < ActiveRecord::Migration[6.0]
  def change
    create_table :feedbacks do |t|
      t.references :user, foreign_key: true, null: false
      t.text :message
      t.integer :rating, default: 1
      t.timestamps
    end
  end
end
