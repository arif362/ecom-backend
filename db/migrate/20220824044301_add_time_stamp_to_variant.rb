class AddTimeStampToVariant < ActiveRecord::Migration[6.0]
  def change
    add_column :variants, :created_at, :datetime, precision: 6
    add_column :variants, :updated_at, :datetime, precision: 6
  end
end
