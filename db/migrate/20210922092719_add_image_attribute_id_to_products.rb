class AddImageAttributeIdToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :image_attribute_id, :integer
  end
end
