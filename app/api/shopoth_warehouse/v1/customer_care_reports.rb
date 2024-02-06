# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class CustomerCareReports < ShopothWarehouse::Base
      resource :customer_care do
        params do
          requires :order_id, type: Integer
          requires :report_type, type: Integer
        end

        desc 'Report to Customer Care'
        route_setting :authentication, type: RouteDevice
        post 'report' do
          report = @current_route_device.customer_care_reports.new(customer_order_id: params[:order_id], report_type: params[:report_type])
          if report.save!
            status :ok
            { success: true, message: 'Reported' }
          else
            status :unprocessable_entity
            { error: 'Something Went wrong' }
          end
        end
      end
    end
  end
end
