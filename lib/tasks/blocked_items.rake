require 'csv'
namespace :blocked_items do
  task add_blocked: :environment do |t, args|
    csv = CSV.read(Rails.root.join('tmp/csv/blocked_items.csv'),
                   headers: true, col_sep: ',', header_converters: :symbol)
    csv.each_with_index do |row, i|
      variant = Variant.find(row[:variant_id].to_i)
      blocked_item = variant.blocked_items.create!(warehouse_id: 8,
                                                   blocked_quantity: row[:quantity].to_i)
      warehouse_variant = variant.warehouse_variants.find_or_create_by!(warehouse_id: 8)
      warehouse_variant.update_columns(blocked_quantity: warehouse_variant.blocked_quantity + blocked_item.blocked_quantity)
      p "successful index: #{i} and blocked item: #{blocked_item.id}, variant: #{row[:variant_id]}"

    rescue StandardError => error
      p "failed index: #{i}"
      p "Blocked creation failed index:#{i} name: #{row[:variant_id]} #{error.message}"
      next
    end
  end
end
