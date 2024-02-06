class AddReceiveableToPayment < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :receiver_id, :integer
    add_column :payments, :receiver_type, :string
  end
end
