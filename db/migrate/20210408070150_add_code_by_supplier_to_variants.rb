class AddCodeBySupplierToVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :variants, :code_by_supplier, :string
  end
end
