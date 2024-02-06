require 'csv'
namespace :products do
  desc 'This task will update leaf_category_id, image_attribute_id, attribute_set_id'
  task update: :environment do |t, args|

    Product.all.find_in_batches do |products|
      update_products(products)
    end
  end

  def update_products(products)
    products.each do |product|
      next unless product.variable_product?

      attributes = product.product_attribute_values.map(&:product_attribute).uniq

      attribute_set_title = attributes.map(&:name).sort.join('-').downcase

      attribute_set = AttributeSet.find_by(title: attribute_set_title)

      unless attribute_set
        attribute_set = AttributeSet.create(title: attribute_set_title)
        attributes.each do |product_attribute|
          attribute_set.attribute_set_product_attributes.create(product_attribute: product_attribute)
        end
        puts "attribute_set -- #{attribute_set.title} is created"
      end

      product.update_columns(attribute_set_id: attribute_set.id)
      image_attribute = image_attribute(attribute_set)
      product.update_columns(image_attribute_id: image_attribute.id)
      puts "product id #{product.id} is updated"
    rescue StandardError => error
      puts "--- Error for product #{product.id} due to: #{error}"
    end
  end

  def image_attribute(attribute_set)
    attribute_set.product_attributes.find_by(['LOWER(name) = ?', 'color']) ||
      attribute_set.product_attributes.find_by(['LOWER(name) = ?', 'size']) ||
      attribute_set.product_attributes.first
  end

  desc 'This task will update consumer price and consumer discount of the given sku'
  task update_consumer_price: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/consumer_price_changes.csv'),
      headers: true, col_sep: ',', header_converters: :symbol,
    )
    fail_rows = []
    fail_rows << ['variant_id', 'price_consumer', 'consumer_discount', 'discount_type', 'failed cause']

    csv_file.each do |row|
      index += 1
      data = row.to_h
      variant = Variant.unscoped.find_by(id: data[:variant_id].to_i)
      if data[:price_consumer].to_i <= 0 || variant.blank?
        row << (data[:price_consumer].to_i <= 0 ? 'MRP should not 0 or negative' : 'variant not found')
        fail_rows << row
        next
      end

      # TODO: Need to change effective_price calculation if the discount_type isn't fixed.
      effective_price = consumer_effective_amount(data[:price_consumer].to_i, data[:consumer_discount].to_f, 'fixed')
      variant.update_columns(price_consumer: data[:price_consumer].to_i,
                             consumer_discount: data[:consumer_discount].to_f,
                             effective_mrp: effective_price,
                             price_retailer: effective_price,
                             price_agami_trade: effective_price,
                             price_distribution: effective_price,
                             discount_type: :fixed)
      puts "#{index}: successfully updated with variant_id - #{data[:variant_id]} "
    rescue StandardError => error
      Rails.logger.info error.full_message.to_s
      puts "Error occurred row number: #{index}, #{error.full_message}"
    end
    filename = 'tmp/csv/failed_rows.csv'
    File.write(filename, fail_rows.map(&:to_csv).join) if fail_rows.length.positive?
  end

  desc 'This task will block the given variants'
  task block_variants: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/block_variants.csv'),
      headers: true, col_sep: ',', header_converters: :symbol,
    )
    fail_rows = []
    fail_rows << ['variant_id', 'warehouse_id', 'blocked_quantity', 'location_id', 'blocked_reason','failed_reason']

    csv_file.each do |row|
      index += 1
      data = row.to_h
      warehouse = Warehouse.find_by(id: data[:warehouse_id].to_i)
      variant = Variant.unscoped.find_by(id: data[:variant_id].to_i)
      quantity = data[:blocked_quantity].to_i

      location = warehouse.locations.find_by(id: data[:location_id].to_i)
      unless location
        row << 'Location not found'
        fail_rows << row
        next
      end

      warehouse_variant = warehouse.warehouse_variants.find_by(variant_id: variant.id)
      unless warehouse_variant
        row << 'Warehouse variant not found'
        fail_rows << row
        next
      end

      wv_location = warehouse_variant.warehouse_variants_locations.find_by(location: location)
      unless wv_location
        row << 'Warehouse_variant_location not found'
        fail_rows << row
        next
      end

      blocked_reason = data[:blocked_reason].to_i
      unless blocked_reason.present?
        row << 'Blocked Reason not found'
        fail_rows << row
        next
      end

      if warehouse_variant.available_quantity >= quantity && wv_location.quantity >= quantity
        make_block_and_garbage(warehouse, quantity, blocked_reason, variant, warehouse_variant, wv_location, index)
      else
        make_block_and_garbage(warehouse, warehouse_variant.available_quantity, blocked_reason, variant, warehouse_variant, wv_location, index)
      end
    rescue StandardError => error
      Rails.logger.info error.full_message.to_s
      puts "Error occurred row number: #{index}, #{error.full_message}"
      row << "Error occurred row number: #{index}, #{error.full_message}"
      fail_rows << row
      next
    end
    filename = 'tmp/csv/failed_rows.csv'
    File.write(filename, fail_rows.map(&:to_csv).join)
  end

  def make_block_and_garbage(warehouse, quantity, blocked_reason, variant, warehouse_variant, wv_location, index)
    blocked_item = warehouse.blocked_items.find_or_create_by(blocked_quantity: quantity,
                                                  blocked_reason: blocked_reason,
                                                  variant: variant)

    update_warehouse_quantity(blocked_item, warehouse_variant, wv_location, quantity)
    puts "#{index}: successfully blocked with variant_id - #{warehouse_variant.variant_id} "

    update_garbage_quantity(blocked_item, warehouse_variant, blocked_item.blocked_quantity)
    puts "successfully #{blocked_item.blocked_quantity} quantity moved into garbage for blocked_item id- #{blocked_item.id} "
  end

  def update_warehouse_quantity(blocked_item, warehouse_variant, wv_location, quantity)
    warehouse_variant.update!(
      available_quantity: warehouse_variant.available_quantity - quantity,
      blocked_quantity: warehouse_variant.blocked_quantity + quantity,
    )
    wv_location.update!(quantity: wv_location.quantity - quantity)
    warehouse_variant.save_stock_change('sku_block', quantity, blocked_item, 'available_quantity_change', 'blocked_quantity_change')
  end

  def update_garbage_quantity(blocked_item, warehouse_variant, quantity)
    blocked_item.update!(garbage_quantity: blocked_item.garbage_quantity + quantity)
    warehouse_variant.update!(blocked_quantity: warehouse_variant.blocked_quantity - quantity)
    warehouse_variant.save_stock_change('garbage_blocked_sku', quantity, blocked_item, 'blocked_quantity_change', 'garbage_quantity_change')
  end

  def consumer_effective_amount(price_consumer, consumer_discount, discount_type)
    discount = if discount_type == 'percentage'
                 price_consumer * consumer_discount / 100
               else
                 consumer_discount
               end

    (price_consumer - discount).ceil(0)
  end
end
