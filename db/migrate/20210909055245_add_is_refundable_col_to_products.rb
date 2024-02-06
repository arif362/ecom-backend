class AddIsRefundableColToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :is_refundable, :boolean, default: true
    add_column :products, :return_policy, :text, default: ''
  end
end
