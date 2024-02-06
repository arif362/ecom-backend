class AddDeletedFlagProductColumn < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :is_deleted, :boolean, default: false
  end
end
