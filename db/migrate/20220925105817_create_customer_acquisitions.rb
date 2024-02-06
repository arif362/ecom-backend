class CreateCustomerAcquisitions < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_acquisitions do |t|
      t.bigint :user_id
      t.bigint :registered_by_id
      t.string :registered_by_type
      t.float :amount
      t.bigint :coupon_id

      t.timestamps
    end
  end
end
