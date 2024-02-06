class AddBnReturnPolicyInProductTable < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :bn_return_policy, :text, default: ''
  end
end
