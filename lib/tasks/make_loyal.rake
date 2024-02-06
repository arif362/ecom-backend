require 'csv'
namespace :make_loyal do
  desc 'This task creates loyal customer'
  task customer: :environment do |t, args|
    file = Rails.root.join('public/seed_data/users.csv')

    CSV.foreach(file, :headers => true) do |cs|
      customer = cs.to_h
      user = User.find_by(phone: customer["phone"])
      if user.present?
        user.update!(is_loyal: true)
        message = "Shopoth.com is delighted to announce that you've become our loyal customer. To buy products from Shopoth.com as loyal customer, please login with your phone number and password."
        SmsManagement::SendMessage.call(phone: user.phone, message: message)
      else
        password = (SecureRandom.random_number(9e5)+ 1e5).to_i.to_s
        if User.create!({
                          phone: customer["phone"],
                          is_loyal: true,
                          status: 'active',
                          password: password,
                          password_confirmation: password
                        })
          message = "Shopoth.com is delighted to announce that you've become our loyal customer. To buy products from Shopoth.com as loyal customer, please login with this phone number #{user.phone} and password: #{password}"
          SmsManagement::SendMessage.call(phone: user.phone, message: message)
        end
      end
    end
  rescue => ex
    puts "--- Error loyal customer csv import due to: #{ex}"
  end
end
