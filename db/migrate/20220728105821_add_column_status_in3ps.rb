class AddColumnStatusIn3ps < ActiveRecord::Migration[6.0]
  def change
    add_column :third_party_users, :status, :integer, default: 0
  end
end
