class AddReportableToCustomerCareReport < ActiveRecord::Migration[6.0]
  def change
    add_reference :customer_care_reports, :reporter, polymorphic: true
  end
end
