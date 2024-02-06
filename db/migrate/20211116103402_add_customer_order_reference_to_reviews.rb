class AddCustomerOrderReferenceToReviews < ActiveRecord::Migration[6.0]
  def change
    add_reference :reviews, :customer_order, foreign_key: true
  end
end
