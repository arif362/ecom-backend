class AddTitleBnToPromotion < ActiveRecord::Migration[6.0]
  def change
    add_column :promotions, :title_bn, :string, default: ''
  end
end
