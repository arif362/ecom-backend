class AddAttributeSetReferenceToProduct < ActiveRecord::Migration[6.0]
  def change
    add_reference :products, :attribute_set, foreign_key: true
  end
end
