require 'csv'
namespace :inventory do
  task update_variants_quantity: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/warehouse_variant.csv'),
      headers: true, col_sep: ',', header_converters: :symbol
    )
    csv_file.each do |row|
      index += 1
      data = row.to_h

      variant = Variant.find(data[:variant_id].to_i)
      warehouse_variant = variant.warehouse_variants.find_or_create_by(warehouse_id: data[:warehouse_id].to_i)

      warehouse_variant.update(available_quantity: data[:available_quantity].to_i,
                               booked_quantity: data[:booked_quantity].to_i,
                               packed_quantity: data[:packed_quantity].to_i,
                               in_transit_quantity: data[:in_transit_quantity].to_i,
                               in_partner_quantity: data[:in_partner_quantity].to_i
      )
      puts "#{index}: successfully updated with variant id - #{variant.id}  and warehouse id - #{data[:warehouse_id].to_i}"
    rescue => ex
      Rails.logger.info "#{ex.full_message}"
      puts "Error occurred row number: #{index}, #{ex.full_message}"
    end
  end

  task update_location_quantity: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/warehouse_variant_location.csv'),
      headers: true, col_sep: ',', header_converters: :symbol
    )
    csv_file.each do |row|
      index += 1
      data = row.to_h

      variant = Variant.find(data[:variant_id].to_i)
      warehouse_variant = variant.warehouse_variants.find_by(warehouse_id: data[:warehouse_id].to_i)
      if warehouse_variant.present?
        warehouse_variant_location = warehouse_variant.warehouse_variants_locations.find_or_create_by(location_id: data[:location_id].to_i)
        warehouse_variant_location.update(quantity: data[:quantity].to_i)
        puts "#{index}: successfully updated with variant id - #{variant.id}} and warehouse id - #{data[:warehouse_id].to_i}}"
      else
        puts "#{index}: Variant id #{variant.id}} is not present in warehouse id #{data[:warehouse_id].to_i}"
      end
    rescue => ex
      Rails.logger.info "#{ex.full_message}"
      puts "Error occurred row number: #{index}, #{ex.full_message}"
    end
  end

  task reduce_available_quantity: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/warehouse_variant.csv'),
      headers: true, col_sep: ',', header_converters: :symbol
    )
    csv_file.each do |row|
      index += 1
      data = row.to_h

      variant = Variant.find(data[:variant_id].to_i)
      warehouse_variant = variant.warehouse_variants.find_by(warehouse_id: data[:warehouse_id].to_i)

      warehouse_variant.update(available_quantity: warehouse_variant.available_quantity - data[:available_quantity].to_i)
      puts "#{index}: successfully updated with variant id - #{variant.id}  and warehouse id - #{data[:warehouse_id].to_i}"
    rescue => ex
      Rails.logger.info "#{ex.full_message}"
      puts "Error occurred row number: #{index}, #{ex.full_message}"
    end
  end

end
