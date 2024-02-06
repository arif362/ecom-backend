class CreateCustomerCareReport < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_care_reports do |t|
      t.integer :report_type, default: 0
      t.references :customer_order, null: false, foreign_key: true
    end
  end
end
