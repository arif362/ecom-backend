class RemoveObjectTypeObjectIdFromMetaData < ActiveRecord::Migration[6.0]
  def change
    remove_column :meta_data, :object_type, :integer
  end
end
