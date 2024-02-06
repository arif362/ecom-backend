class CustomerCareReport < ApplicationRecord
  after_create :submit_report

  belongs_to :customer_order
  belongs_to :reporter, polymorphic: true

  enum report_type: { time_extension: 0,
                      product_return: 1,
                      parnter_outlet_closed: 2,
                      partner_rejected_to_receive: 3,
                      partner_application_not_working: 4,
                      customer_unreachable: 5,
                      customer_declined_to_receive: 6,
                      customer_wants_to_reschedule: 7,
                      doorstep_return: 8, }

  def submit_report
    CustomerCareReports::SubmitReport.call(
      order_id: customer_order_id,
      description: report_type,)
  end
end
