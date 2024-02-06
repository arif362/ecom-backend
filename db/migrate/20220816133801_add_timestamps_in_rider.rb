class AddTimestampsInRider < ActiveRecord::Migration[6.0]
  def change
    add_column :riders, :created_at, :datetime, precision: 6
    add_column :riders, :updated_at, :datetime, precision: 6
  end
end
