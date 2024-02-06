class AddB2bEffectiveMrpOnVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :variants, :b2b_effective_mrp, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
