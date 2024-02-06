require 'csv'

namespace :product_category do
  task update: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/product_category.csv'),
      headers: true, col_sep: ',', header_converters: :symbol
    )
    # CSV.foreach(csv_file, headers: true) do |row|
    csv_file.each do |row|
      index += 1
      data = row.to_h
      category_id = data[:category_id].to_i
      current_category = Category.find(category_id)

      product = Product.find(data[:product_id].to_i)
      # Removing entries from product_categories table
      product.product_categories.delete_all
      # Assuming this is leaf category that is provided
      current_category.product_categories.create(product: product)
      product.update(leaf_category_id: current_category.id)

      current_cat_parent = current_category.parent
      while current_cat_parent.present?
        current_cat_parent.product_categories.create(product: product)
        if current_cat_parent.parent.nil?
          product.update(root_category_id: current_cat_parent.id)
        end
        current_cat_parent = current_cat_parent.parent
      end
      puts "#{index}: successfully updated with product id - #{product.id}, leaf category id - #{product.leaf_category_id} root category id - #{product.root_category_id}"
    rescue => ex
      Rails.logger.info "#{ex.full_message}"
      puts "Error occurred row number: #{index}, #{ex.full_message}"
    end
  end
end
