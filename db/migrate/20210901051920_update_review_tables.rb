class UpdateReviewTables < ActiveRecord::Migration[6.0]
  def change
    remove_column :reviews, :body, :text
    remove_column :reviews, :product_id, :integer
    remove_column :reviews, :review_type, :integer
    remove_column :reviews, :is_approved, :boolean
    add_column :reviews, :description, :string
    add_column :reviews, :shopoth_line_item_id, :integer
    add_reference :reviews, :variant, index: true
  end
end
