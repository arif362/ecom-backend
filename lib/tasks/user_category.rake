require 'csv'

namespace :user_category do
  task make_feild_force: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/force_field_users.csv'),
      headers: true, col_sep: ',', header_converters: :symbol
    )
    # CSV.foreach(csv_file, headers: true) do |row|
    csv_file.each do |row|
      index += 1
      data = row.to_h
      user_id = data[:user_id].to_i
      user = User.find(user_id)
      user.update_columns(category: User.categories[:field_force])

    rescue => ex
      Rails.logger.info "#{ex.full_message}"
      puts "Error occurred row number: #{index}, #{ex.full_message}"
    end
  end

  task make_cs_agent: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/force_field_users.csv'),
      headers: true, col_sep: ',', header_converters: :symbol
    )
    # CSV.foreach(csv_file, headers: true) do |row|
    csv_file.each do |row|
      index += 1
      data = row.to_h
      user_id = data[:user_id].to_i
      user = User.find(user_id)
      user.update_columns(category: User.categories[:cs_agent])

    rescue => ex
      Rails.logger.info "#{ex.full_message}"
      puts "Error occurred row number: #{index}, #{ex.full_message}"
    end
  end
end
