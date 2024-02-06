class CreateReviews < ActiveRecord::Migration[6.0]
  def change
    drop_table :reviews if (table_exists? :reviews)
    create_table :reviews do |t|
      t.string "title", null: false
      t.text "body"
      t.integer "rating", default: 0
      t.integer "product_id", index: true
      t.integer "user_id"
      t.boolean "is_approved", default: true
      t.integer "review_type"

      t.timestamps
    end
  end
end
