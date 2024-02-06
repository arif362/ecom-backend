class AddConfigurationToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :configuration, :string
  end
end
