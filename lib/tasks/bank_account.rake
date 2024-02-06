require 'csv'
namespace :bank_account do
  desc 'create bank account for DH'
  task create_bank_account_dh: :environment do |t, args|
    csv_file = CSV.read(Rails.root.join('tmp/csv/dh_bank_account.csv'),
                        headers: true, col_sep: ',', header_converters: :symbol)
    fail_rows = []
    fail_rows << %w(title bank_name account_name account_number branch_name distributor_id note reason)
    note = ''
    csv_file.each_with_index do |row, index|
      data = row.to_h
      bank_account = BankAccount.find_by(account_number: data[:account_number])
      unless bank_account.blank?
        row << 'Account already exists'
        fail_rows << row
        next
      end

      mandatory_values = [data[:title], data[:bank_name], data[:account_name],
                        data[:account_number], data[:branch_name],
                        data[:distributor_id],]
      unless mandatory_values.all?
        row << 'All required fields must exist'
        fail_rows << row
        next
      end
      title = data[:title]
      bank_name = data[:bank_name]
      account_name = data[:account_name]
      account_number = data[:account_number]
      branch_name = data[:branch_name]
      ownerable_id = data[:distributor_id]
      note = data[:note] if data[:note].present?
      BankAccount.create!(title: title, bank_name: bank_name,
                          account_name: account_name, account_number: account_number,
                          branch_name: branch_name, ownerable_id: ownerable_id,
                          ownerable_type: 'Distributor', note: note)
    rescue StandardError => error
      Rails.logger.info error.full_message.to_s
      puts "Error occurred in row number: #{index}, error: #{error.full_message}"
    end
    filename = 'tmp/csv/failed_rows_bank_account.csv'
    File.write(filename, fail_rows.map(&:to_csv).join) if fail_rows.length.positive?
  end
end
