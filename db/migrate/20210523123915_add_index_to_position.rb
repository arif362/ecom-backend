class AddIndexToPosition < ActiveRecord::Migration[6.0]
  def change
    add_index :categories, :position
  end
end
