class AddIsCommissionableColToDistributors < ActiveRecord::Migration[6.0]
  def change
    add_column :distributors, :is_commission_applicable, :boolean, default: true
  end
end
