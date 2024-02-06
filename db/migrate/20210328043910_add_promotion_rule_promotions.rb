class AddPromotionRulePromotions < ActiveRecord::Migration[6.0]
  def change
    add_column :promotions, :rule, :string
  end
end
