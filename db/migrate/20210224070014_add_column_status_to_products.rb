class AddColumnStatusToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :status, :string, default: 'new'
  end
end
