class ChangeStatusOfBundleTable < ActiveRecord::Migration[6.0]
  def change
    remove_column :bundles, :status, :integer
    add_column :bundles, :is_editable, :boolean, default: true
  end
end
