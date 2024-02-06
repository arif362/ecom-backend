class CreateAttributeSetProductAttributes < ActiveRecord::Migration[6.0]
  def change
    create_table :attribute_set_product_attributes do |t|
      t.references :attribute_set, null: false, foreign_key: true
      t.references :product_attribute, null: false, foreign_key: true
    end
  end
end
