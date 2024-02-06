require 'csv'
namespace :users do
  desc 'change is_otp_verified to false'
  task update_is_otp_verified: :environment do |t, args|
    csv_file = CSV.read(Rails.root.join('tmp/csv/unverified_users.csv'),
                        headers: true, col_sep: ',', header_converters: :symbol)
    fail_rows = []
    fail_rows << %w(user_id)
    csv_file.each_with_index do |row, index|
      data = row.to_h
      user = User.find_by(id: data[:user_id].to_i)
      if user.present?
        user.update_columns(is_otp_verified: false)
        puts "#{index}: successfully updated user, - #{data[:user_id].to_i}"
      else
        fail_rows << row
      end
    rescue StandardError => error
      Rails.logger.info error.full_message.to_s
      puts "Error occurred in row number: #{index}, error: #{error.full_message}"
    end

    filename = 'tmp/csv/failed_rows_user_is_otp_varified.csv'
    File.write(filename, fail_rows.map(&:to_csv).join) if fail_rows.length.positive?
  end
end

