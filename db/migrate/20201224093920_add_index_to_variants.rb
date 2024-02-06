class AddIndexToVariants < ActiveRecord::Migration[6.0]
  def change
    add_index :variants, :product_id
  end
end
