class RemoveColSocialLinks < ActiveRecord::Migration[6.0]
  def change
    remove_column :social_links, :store_info_id, :integer
  end
end
