# frozen_string_literal: true

module Finance
  module V1
    class CustomerAcquisitions < Finance::Base
      resource :customer_acquisitions do
        desc 'Customer Acquisitions'
        params do
          use :pagination, per_page: 30, offset: 0
          optional :acquisition_by, type: String, values: %w[Ambassador Partner SR]
          optional :is_paid, type: Boolean, values: [true, false]
          requires :start_date_time, type: DateTime
          requires :end_date_time, type: DateTime
          optional :skip_pagination, type: Boolean
        end
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.utc.beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.utc.end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
            error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          
          acquisitions = CustomerAcquisition.
            where(created_at: start_date_time..end_date_time).
            where.not(information_status: :incomplete).
            order(id: :desc)
          if params[:acquisition_by].present?
            acquisition_by = params[:acquisition_by] == 'Partner' ? 'Partner' : params[:acquisition_by] == 'SR' ? 'RouteDevice' : 'User'
            acquisitions = acquisitions.where(registered_by_type: acquisition_by)
          end
          acquisitions = acquisitions.where(is_paid: params[:is_paid]) unless params[:is_paid].nil?
          # TODO: Need to Optimize Query
          acquisitions = paginate(Kaminari.paginate_array(acquisitions)) unless params[:skip_pagination]
          success_response_with_json('Successfully fetch customer acquisition list', HTTP_CODE[:OK],
                                     Finance::V1::Entities::CustomerAcquisitions.represent(acquisitions, list: true))
        rescue StandardError => error
          Rails.logger.info "Unable to fetch the customer acquisition list due to #{error.message}."
          error!(failure_response_with_json("Unable to fetch the customer acquisition list due to #{error.message}.",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end


        desc 'Adopt Manual Payment For Customer Acquisition'
        params do
          requires :file, type: File
        end
        put :update_payment_status do
          valid_file_type = %w(.csv application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.ms-excel text/comma-separated-values text/csv application/csv)

          file = params[:file]
          file_path = File.expand_path(file['tempfile'])
          
          unless valid_file_type.include?(file['type'])
            error!(failure_response_with_json('Please provide CSV or XLSX file.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          csv_file = CSV.read(file_path, headers: true, col_sep: ',', header_converters: :symbol)

          required_columns = [:id, :is_paid]
          unless (required_columns - csv_file&.headers).empty?
            error!(failure_response_with_json('Required column is missing on given file, id & is_pad is required as column.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          headers = [*csv_file&.headers, :response, :error_message]
          csv_data = CSV.generate(headers: true) do |csv|
            csv << headers
            csv_file.each do |row|
              begin
                data = row.to_h
                new_row = row.fields

                acquisition_id = data[:id].to_i
                is_paid = %w[y yes t true].include?(data[:is_paid].to_s.strip.downcase) ? true : false

                unless is_paid
                  new_row << 'Skip'
                  csv << new_row
                  next
                end

                acquisition = CustomerAcquisition.find_by(id: acquisition_id)
                unless acquisition
                  new_row << 'Error' << 'Acquisition Not Found'
                  csv << new_row
                  next
                end

                if acquisition.is_paid
                  new_row << 'Already Paid'
                  csv << new_row
                  next
                end

                if acquisition.incomplete?
                  new_row << 'Error' << 'Incomplete Acquisition'
                  csv << new_row
                  next
                end

                acquisition.update!(is_paid: true)
                new_row << 'Success'
                csv << new_row
              rescue StandardError => error
                new_row << 'Error' << "#{error.message}"
                csv << new_row
              end
            end
          end
          AcquisitionMailer.send_csv_attachment(csv_data, "payment_status_update_report.csv").deliver_later
          success_response_with_json('Successfully update acquisition payment status', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.info "Unable to update acquisition payment status due to #{error.message}"
          error!(failure_response_with_json('Unable to update acquisition payment status',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
