namespace :warehouse do
  desc 'This task creates warehouse and shopoth admin'
  task setup: :environment do |t, args|
    puts 'Starting warehouse setup...'
    print 'Warehouse admin email: '
    email = STDIN.gets.chomp
    print 'Warehouse admin password: '
    password = STDIN.gets.chomp

    wh = Warehouse.find_by(email: email)
    if wh.nil?
      Warehouse.create!(
        name: 'Central Warehouse',
        warehouse_type: Warehouse::WAREHOUSE_TYPES[:central],
        email: email,
        password: password,
        password_confirmation: password
      )
    else
      puts "--- Warehouse with email \"#{email}\" is already exists!"
    end
  rescue => ex
    puts "--- Error configuring warehouse due to: #{ex}"
  end
end
