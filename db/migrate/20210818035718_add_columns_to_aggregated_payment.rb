class AddColumnsToAggregatedPayment < ActiveRecord::Migration[6.0]
  def change
    add_column :aggregated_payments, :month, :integer, default: 0
    add_column :aggregated_payments, :year, :integer
    add_column :aggregated_payments, :partner_schedule, :integer, default: 0
    add_column :aggregated_payments, :received_by_id, :integer
    add_column :aggregated_payments, :received_by_type, :string
  end
end
