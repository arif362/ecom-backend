class AddDistributorIdInThana < ActiveRecord::Migration[6.0]
  def change
    add_column :thanas, :distributor_id, :integer
  end
end
