class RemoveColStoreInfos < ActiveRecord::Migration[6.0]
  def change
    remove_column :store_infos, :social_link_id, :integer
  end
end
