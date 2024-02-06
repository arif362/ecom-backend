class ChangeReviewTableStructure < ActiveRecord::Migration[6.0]
  def change
    add_reference :reviews, :reviewable, polymorphic: true, index: true
    add_column :reviews, :is_recommended, :boolean, default: false
    remove_column :reviews, :variant_id
  end
end
