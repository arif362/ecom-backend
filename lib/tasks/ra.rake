require 'csv'
namespace :retailer_assistant do
  desc 'add distributor_id in retailer assistant'
  task update_distributor_id: :environment do |t, args|
    csv_file = CSV.read(Rails.root.join('tmp/csv/dh_ra.csv'),
                        headers: true, col_sep: ',', header_converters: :symbol)
    fail_rows = []
    fail_rows << %w(ra_id distributor_id)
    csv_file.each_with_index do |row, index|
      data = row.to_h
      retailer_assistant = RetailerAssistant.find_by(id: data[:id].to_i)
      if retailer_assistant.present?
        retailer_assistant.update!(distributor_id: data[:distributor_id].to_i)
        puts "#{index}: successfully updated with distributor id - #{data[:distributor_id].to_i}"
      else
        fail_rows << row
      end
    rescue StandardError => error
      Rails.logger.info error.full_message.to_s
      puts "Error occurred in row number: #{index}, error: #{error.full_message}"
    end

    filename = 'tmp/csv/failed_rows_ra_dis.csv'
    File.write(filename, fail_rows.map(&:to_csv).join) if fail_rows.length.positive?
  end
end
