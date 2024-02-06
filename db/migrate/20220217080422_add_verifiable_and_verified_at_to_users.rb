class AddVerifiableAndVerifiedAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :verifiable, polymorphic: true, index: true
    add_column :users, :verified_at, :datetime
  end
end
