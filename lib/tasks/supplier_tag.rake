require 'csv'
require 'bigdecimal'
require 'bigdecimal/util'

namespace :supplier_taggings do
  task execute: :environment do |t, args|
    index = 0
    csv_file = CSV.read(Rails.root.join('tmp/csv/supplier_tag.csv'), headers: true , col_sep: ',', header_converters: :symbol)
    # CSV.foreach(csv_file, headers: true) do |row|
    csv_file.each do |row|
      index += 1
      data = row.to_h
      variant = Variant.find(data[:variant_id].to_i)
      supplier = Supplier.find(data[:supplier_id].to_i)

      suppliers_variants = variant.suppliers_variants.find_or_create_by(supplier: supplier)
      suppliers_variants.update_attributes!(supplier_price: data[:supplier_price].to_d)

      variant.update_attributes!(
        price_consumer: data[:price_consumer].to_d,
        consumer_discount: data[:consumer_discount].to_d,
        discount_type: Variant.discount_types[data[:discount_type].to_s]
      )
      puts "#{index}: Price update for Supplier #{supplier.id} and variant #{variant.id}"
    end
  rescue => ex
    puts "Error in row #{index}. #{ex.full_message}"
  end
end
