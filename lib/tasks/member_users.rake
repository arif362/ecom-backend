require 'csv'
namespace :member_users do
  task create_or_update: :environment do |t, args|
    csv = CSV.read(Rails.root.join('tmp/csv/member_users.csv'),
                   headers: true, col_sep: ',', header_converters: :symbol)
    csv.each_with_index do |row, i|
      phone = row[:phone].to_s.strip
      user = User.find_by_phone(phone)
      if user.present?
        user.update!(user_type: :member)
        p "Member update index-#{i}"
      else
        pass = "Agami#{phone.last(4)}"
        new_user = User.new(first_name: row[:first_name].strip,
                            last_name: row[:last_name].strip,
                            phone: phone,
                            email: row[:email].strip,
                            password: pass,
                            password_confirmation: pass,
                            user_type: :member,
                            is_otp_verified: true)
        new_user.save!
        p "Member create index-#{i}"
      end
    rescue => ex
      p "failed index: #{i}"
      p "member_create_failed. index:#{i} phone: #{row[:phone]} #{ex.message}"
    end
  end
end
