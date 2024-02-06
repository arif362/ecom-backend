class RefactorPartnerMargin < ActiveRecord::Migration[6.0]
  def change
    remove_column :partner_margins, :payment_id
    add_column :partner_margins, :route_received_at, :datetime
    add_column :partner_margins, :partner_received_at, :datetime
    add_column :partner_margins, :route_received_amount, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :partner_margins, :partner_received_amount, :decimal, precision: 10, scale: 2, default: 0.0
    rename_column :partner_margins, :amount, :margin_amount
  end
end
