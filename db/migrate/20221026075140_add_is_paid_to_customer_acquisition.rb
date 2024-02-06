class AddIsPaidToCustomerAcquisition < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_acquisitions, :is_paid, :boolean, default: false
    add_column :customer_acquisitions, :information_status, :integer, null: false, default: 0
  end
end
