require 'csv'
namespace :rider do
  desc 'This task creates notification for SR'
  task app_notification: :environment do |t, args|
    Rider.all.each do |rider|
      ready_orders = rider.customer_orders
                       .where(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_shipment])).count

      if ready_orders > 0
        rider.app_notifications.create(message: "You have #{ready_orders} orders to deliver",
                                       title: 'Order Delivery')
      end
    end
  rescue StandardError => error
    puts "--- Error configuring rider notification due to: #{error}"
  end

  desc 'add distributor_id in rider'
  task update_distributor_id: :environment do |t, args|
    csv_file = CSV.read(Rails.root.join('tmp/csv/dh_rider.csv'),
                        headers: true, col_sep: ',', header_converters: :symbol)
    fail_rows = []
    fail_rows << %w(rider_id distributor_id)
    csv_file.each_with_index do |row, index|
      data = row.to_h
      rider = Rider.find_by(id: data[:id].to_i)
      if rider.present?
        rider.update!(distributor_id: data[:distributor_id].to_i)
        puts "#{index}: successfully updated with distributor id - #{data[:distributor_id].to_i}"
      else
        fail_rows << row
      end
    rescue StandardError => error
      Rails.logger.info error.full_message.to_s
      puts "Error occurred in row number: #{index}, error: #{error.full_message}"
    end

    filename = 'tmp/csv/failed_rows_rider_dis.csv'
    File.write(filename, fail_rows.map(&:to_csv).join) if fail_rows.length.positive?

  end

end
