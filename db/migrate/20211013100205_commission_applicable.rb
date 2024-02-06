class CommissionApplicable < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :is_commission_applicable, :boolean, default: true
    add_column :warehouses, :is_commission_applicable, :boolean, default: true
  end
end
