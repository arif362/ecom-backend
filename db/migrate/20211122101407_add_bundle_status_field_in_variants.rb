class AddBundleStatusFieldInVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :variants, :bundle_status, :integer
  end
end
