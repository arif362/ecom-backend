class AddRedirectUrlColumnInBrandsTabel < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :redirect_url, :string
  end
end
