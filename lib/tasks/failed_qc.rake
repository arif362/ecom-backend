require 'csv'
namespace :failed_qc do
  # NOTE: This task is not allow for in general sto creation
  desc 'Create STO only for specific variant'
  task create_sto: :environment do |t, args|
    csv = CSV.read(Rails.root.join('tmp/csv/failed_qcs.csv'),
                   headers: true, col_sep: ',', header_converters: :symbol)
    total_price = 0
    total_quantity = 0

    csv.each_with_index do |row, i|
      variant_id = row[:variant_id].to_i
      quantity = row[:failed_quantity].to_i
      variant = Variant.find(variant_id)
      price = variant.price_distribution.to_d
      total_price += price * quantity.to_d
      total_quantity += quantity
      LineItem.create!(variant_id: variant_id, quantity: quantity, price: price)
      p "successful index: #{i} and variant: #{row[:variant_id]}"

    end

    dh_po = DhPurchaseOrder.create!(warehouse_id: 8,
                                    quantity: total_quantity,
                                    total_price: total_price,
                                    order_date: DateTime.now)

    LineItem.where(itemable_type: nil).order(created_at: :desc).limit(96).update_all(itemable_type: 'DhPurchaseOrder', itemable_id: dh_po.id)

  end
end
