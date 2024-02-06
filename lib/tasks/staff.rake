require 'csv'
namespace :staffs do
  desc 'create staff'
  task create_staff: :environment do |t, args|
    csv_file = CSV.read(Rails.root.join('tmp/csv/dh_staff.csv'),
                        headers: true, col_sep: ',', header_converters: :symbol)
    fail_rows = []
    fail_rows << %w(first_name last_name email unit staff_role_id warehouse_id is_active
                    staffable_id staffable_type address_line password password_confirmation reason)
    csv_file.each_with_index do |row, index|
      data = row.to_h
      staff = Staff.find_by(email: data[:email])
      distributor = Distributor.find_by(id: data[:staffable_id])
      unless staff.blank?
        row << 'Staff already exist'
        fail_rows << row
        next
      end
      unless distributor.present?
        row << 'Distributor not found'
        fail_rows << row
        next
      end
      mandatory_values = [data[:first_name], data[:last_name], data[:email],
                          data[:password], data[:password_confirmation],
                          data[:staffable_id], data[:staffable_type], data[:staff_role_id],]
      unless mandatory_values.all?
        row << 'All required fields must exist'
        fail_rows << row
        next
      end
      unless data[:password] == data[:password_confirmation]
        row << 'Password didn\'t match'
        fail_rows << row
        next
      end
      unit_fields = %w(fulfilment_center central_warehouse customer_care finance dh_panel three_ps)
      unless unit_fields.include?(data[:unit])
        row << 'unit not valid'
        fail_rows << row
        next
      end
      staff_type = %w(Distributor Warehouse CustomerCareAgent ThirdPartyUser)
      unless staff_type.include?(data[:staffable_type])
        row << 'staffable_type is not valid'
        fail_rows << row
        next
      end
      unit_type_validation = data[:staffable_type] == 'Distributor' && data[:unit] == 'dh_panel' ||
                             data[:staffable_type] == 'Warehouse' &&
                             %w(fulfilment_center central_warehouse finance).include?(data[:unit]) ||
                             data[:staffable_type] == 'CustomerCareAgent' && data[:unit] == 'customer_care' ||
                             data[:staffable_type] == 'ThirdPartyUser' && data[:unit] == 'three_ps'
      unless unit_type_validation
        row << "Incorrect staffable_type: '#{data[:staffable_type]}' and unit: '#{data[:unit]}'"
        fail_rows << row
        next
      end
      first_name = data[:first_name]
      last_name = data[:last_name]
      email = data[:email]
      unit = data[:unit]
      staff_role_id = data[:staff_role_id]
      warehouse_id = data[:warehouse_id].present? ? data[:warehouse_id] : nil
      is_active = data[:is_active]
      staffable_id = data[:staffable_id]
      staffable_type = data[:staffable_type]
      address_line = data[:address_line].present? ? data[:address_line] : ''
      password = data[:password]
      password_confirmation = data[:password_confirmation]
      Staff.create!(first_name: first_name, last_name: last_name,
                    email: email, unit: unit, staff_role_id: staff_role_id,
                    warehouse_id: warehouse_id, is_active: is_active,
                    staffable_id: staffable_id, staffable_type: staffable_type,
                    address_line: address_line, password: password,
                    password_confirmation: password_confirmation)
    rescue StandardError => error
      Rails.logger.info error.full_message.to_s
      puts "Error occurred in row number: #{index}, error: #{error.full_message}"
    end
    filename = 'tmp/csv/failed_rows_staff.csv'
    File.write(filename, fail_rows.map(&:to_csv).join) if fail_rows.length.positive?
  end
end
