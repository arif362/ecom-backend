namespace :warehouse_variants_stock do
  desc 'script for adjusting warehouse variant available quantity except Khulna and Narsingdhi'
  task update: :environment do |_t, _args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/warehouse_variants.csv'),
      headers: true, col_sep: ',', header_converters: :symbol,
    )
    ActiveRecord::Base.transaction do
      csv_file.each do |row|
        index += 1
        data = row.to_h
        wv = WarehouseVariant.find_by(warehouse_id: data[:warehouse_id].to_i,
                                      variant_id: data[:variant_id].to_i)
        wv.available_quantity = data[:available_quantity].to_i if data[:available_quantity].present?
        wv.booked_quantity =  data[:booked_quantity].to_i if data[:booked_quantity].present?
        wv.packed_quantity =  data[:packed_quantity].to_i if data[:packed_quantity].present?
        wv.in_transit_quantity = data[:in_transit_quantity].to_i if data[:in_transit_quantity].present?
        wv.in_partner_quantity = data[:in_partner_quantity].to_i if data[:in_partner_quantity].present?
        wv.blocked_quantity =  data[:blocked_quantity].to_i if data[:blocked_quantity].present?
        wv.qc_pending_quantity =  data[:qc_pending_quantity].to_i if data[:qc_pending_quantity].present?
        wv.qty_qc_failed_quantity =  data[:qty_qc_failed_quantity].to_i if data[:qty_qc_failed_quantity].present?
        wv.qly_qc_failed_quantity =  data[:qly_qc_failed_quantity].to_i if data[:qly_qc_failed_quantity].present?
        wv.location_pending_quantity = data[:location_pending_quantity].to_i if data[:location_pending_quantity].present?
        wv.return_in_partner_quantity =  data[:return_in_partner_quantity].to_i if data[:return_in_partner_quantity].present?
        wv.return_in_transit_quantity =  data[:return_in_transit_quantity].to_i if data[:return_in_transit_quantity].present?
        wv.return_qc_pending_quantity =  data[:return_qc_pending_quantity].to_i if data[:return_qc_pending_quantity].present?
        wv.return_location_pending_quantity = data[:return_location_pending_quantity].to_i if data[:return_location_pending_quantity].present?
        wv.ready_to_ship_from_fc_quantity = data[:ready_to_ship_from_fc_quantity].to_i if data[:ready_to_ship_from_fc_quantity].present?
        wv.in_transit_to_dh_quantity = data[:in_transit_to_dh_quantity].to_i if data[:in_transit_to_dh_quantity].present?
        wv.ready_to_ship_quantity = data[:ready_to_ship_quantity].to_i if data[:ready_to_ship_quantity].present?
        wv.return_in_dh_quantity = data[:return_in_dh_quantity].to_i if data[:return_in_dh_quantity].present?
        wv.return_in_transit_to_fc_quantity = data[:return_in_transit_to_fc_quantity].to_i if data[:return_in_transit_to_fc_quantity].present?
        wv.return_qc_failed_quantity = data[:return_qc_failed_quantity].to_i if data[:return_qc_failed_quantity].present?
        wv.save!
        puts "#{index}: successfully updated warehouse #{wv.warehouse_id} variant id #{wv.variant_id} - and wv-  #{wv.id}"
      end
    rescue StandardError => error
      Rails.logger.info error.full_message.to_s
      puts "Error occurred row number: #{index}, #{error.full_message}"
    end
  end
end
