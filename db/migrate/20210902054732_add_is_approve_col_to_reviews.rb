class AddIsApproveColToReviews < ActiveRecord::Migration[6.0]
  def change
    add_column :reviews, :is_approved, :boolean, default: false
  end
end
