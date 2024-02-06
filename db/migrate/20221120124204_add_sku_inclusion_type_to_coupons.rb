class AddSkuInclusionTypeToCoupons < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :sku_inclusion_type, :integer, default: 0
  end
end
