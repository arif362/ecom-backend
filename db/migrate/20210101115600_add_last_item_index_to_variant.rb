class AddLastItemIndexToVariant < ActiveRecord::Migration[6.0]
  def change
    add_column :variants, :last_item_index, :integer
  end
end
