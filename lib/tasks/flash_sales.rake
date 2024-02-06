require 'csv'
namespace :flash_sales do
  task update_variant_discount: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/flash_sales.csv'),
      headers: true, col_sep: ',', header_converters: :symbol
    )

    # Removing all daily deals
    ProductsProductType.where(product_type_id: 2).delete_all
    
    csv_file.each do |row|
      index += 1
      data = row.to_h

      variant = Variant.find(data[:variant_id].to_i)
      variant.update!(discount_type: data[:flash_discount_type].to_i, consumer_discount: data[:flash_consumer_discount].to_f)
      variant.product.products_product_types.find_or_create_by(product_type_id: 2)

      puts "#{index}: successfully updated with variant id - #{variant.id}  and discount #{variant.consumer_discount}"
    rescue => ex
      Rails.logger.info "#{ex.full_message}"
      puts "Error occurred row number: #{index}, #{ex.full_message}"
    end
  end

  task revert_variant_discount: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/flash_sales.csv'),
      headers: true, col_sep: ',', header_converters: :symbol
    )
    # Removing all daily deals
    ProductsProductType.where(product_type_id: 2).delete_all

    csv_file.each do |row|
      index += 1
      data = row.to_h

      variant = Variant.find(data[:variant_id].to_i)
      variant.update!(discount_type: data[:previous_discount_type].to_i, consumer_discount: data[:previous_consumer_discount].to_f)
      # TODO: Make sure to change the product type id from 1 to something that matches the production server type
      if data[:previous_product_type_id].to_i == 2
        # TODO: change product type also here that matches the production 1 is for development
        variant.product.products_product_types.find_or_create_by(product_type_id: 2)
      end

      puts "#{index}: successfully updated with variant id - #{variant.id}  and discount #{variant.consumer_discount}"
    rescue => ex
      Rails.logger.info "#{ex.full_message}"
      puts "Error occurred row number: #{index}, #{ex.full_message}"
    end
  end

  task restore_product_product_type_table: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/product_product_type.csv'),
      headers: true, col_sep: ',', header_converters: :symbol
    )
    csv_file.each do |row|
      index += 1
      data = row.to_h
      ProductsProductType.find_or_create_by(product_id: data[:product_id].to_i, product_type_id: data[:product_type_id].to_i)
      puts "#{index}: successfully updated with product_id - #{data[:product_id]}  and product_type #{data[:product_type_id]} "
      rescue => ex
        Rails.logger.info "#{ex.full_message}"
        puts "Error occurred row number: #{index}, #{ex.full_message}"
      end
  end
end
