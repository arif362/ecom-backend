require 'csv'

namespace :capex_asset do
  task supplier_create: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/oc_suppliers.csv'),
      headers: true, col_sep: ',', header_converters: :symbol,
    )

    csv_file.each do |row|
      index += 1
      name = row[:name].to_s
      supplier = OcSupplier.find_or_create_by!(name: name)
      puts "#{index}: successfully created oc_supplier #{supplier.name}"
    rescue => ex
      Rails.logger.info "#{ex.full_message}"
      puts "Error occurred row number: #{index}, #{ex.full_message}"
    end
  end

  task oc_categories_product_create: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/oc_products.csv'),
      headers: true, col_sep: ',', header_converters: :symbol,
    )

    csv_file.each do |row|
      index += 1
      cat_title = row[:cat_title].to_s
      product_title = row[:product_title].to_s
      product_model_name = row[:product_model_name].to_s
      root_category = OcCategory.find_or_create_by!(title: cat_title)
      oc_product = OcProduct.find_or_create_by!(title: product_title,
                                                model_title: product_model_name,
                                                root_category: root_category)
      puts "#{index}: successfully created oc_supplier #{oc_product.title}"
    rescue => ex
      Rails.logger.info "#{ex.full_message}"
      puts "Error occurred row number: #{index}, #{ex.full_message}"
    end
  end

  task oc_po_create: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/oc_po.csv'),
      headers: true, col_sep: ',', header_converters: :symbol,
    )
    dummy_po = Hash.new

    csv_file.each do |row|
      index += 1

      if dummy_po.key? row[:oc_po_id].to_i
        po = dummy_po[row[:oc_po_id].to_i]
      else
        supplier = OcSupplier.find(row[:supplier_id].to_i)
        po = OcPurchaseOrder.create!(
          oc_supplier: supplier,
        )
        dummy_po[row[:oc_po_id].to_i] = po
        puts "#{index}:New purchase order created with ID #{po.id}"
      end

      oc_product = OcProduct.find(row[:oc_product_id].to_i)
      unit_price = row[:unit_price].to_f
      quantity = row[:quantity].to_i
      create_oc_line_item(row, po, oc_product, unit_price, quantity)
    rescue => ex
      Rails.logger.info "#{ex.message}"
      puts "Error occurred row number: #{index}, #{ex.message}"
    end
  end

  task asset_create: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/asset.csv'),
      headers: true, col_sep: ',', header_converters: :symbol,
    )
    csv_file.each do |row|
      index += 1
      line_item = OcLineItem.find(row[:line_item_id].to_i)
      location_name = row[:location_name].to_s
      location = AssetLocation.find_or_create_by!(name: location_name)
      CompanyAsset.create!(asset_location: location,
                           oc_line_item: line_item,
                           oc_product_id: line_item.oc_product_id,
                           tag: row[:tag].to_s,
                           details: row[:details].to_s)
    rescue => ex
      Rails.logger.info "#{ex.message}"
      puts "Error occurred row number: #{index}, #{ex.message}"
    end
  end

  def create_oc_line_item(row, po, oc_product, unit_price, quantity)
    oc_item = po.oc_line_items.find_by(oc_product_id: oc_product.id)
    if oc_item.present?
      oc_item.update_columns(quantity: oc_item.quantity + quantity,
                             total_price: oc_item.total_price + (quantity * unit_price))
    else
      po.oc_line_items.create!(
        oc_product: oc_product,
        quantity: quantity,
        unit_price: unit_price,
        total_price: quantity * unit_price,
        acquisition_date: row[:acquisition_date],
      )
    end
    po_quantity = po.oc_line_items.sum(&:quantity)
    po_total_price = po.oc_line_items.sum(&:total_price)
    po.update!(
      quantity: po_quantity,
      total_price: po_total_price,
    )
    po
  end
end
