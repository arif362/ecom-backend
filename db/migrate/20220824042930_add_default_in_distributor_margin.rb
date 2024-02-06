class AddDefaultInDistributorMargin < ActiveRecord::Migration[6.0]
  def change
    change_column_default :distributor_margins, :is_commissionable, true
  end
end
