require 'csv'
namespace :brand_and_slug do

  desc 'Task for slug adding in brands, products'
  task update_product: :environment do |t, args|
    index = 0
    csv_file = CSV.read(
      Rails.root.join('tmp/csv/brand_and_slug.csv'),
      headers: true, col_sep: ',', header_converters: :symbol,
    )

    csv_file.each do |row|
      index += 1
      data = row.to_h

      Rails.logger.info data[:product_id].to_i.to_s

      product = Product.unscoped.find(data[:product_id].to_i)

      brand = Brand.find_or_create_by(name: data[:brand], bn_name: data[:brand], slug: data[:brand].to_s.parameterize, visibility: false)

      product.update_columns(
        slug: product_uniq_slug(product.title),
        brand_id: brand.id,
      )

      puts "#{index}: successfully updated with product id - #{product.id}"
    rescue StandardError => error
      Rails.logger.info error.full_message.to_s
      puts "Error occurred row number: #{index}, #{error.full_message}"
    end
  end

  desc 'Task for slug adding in partners'
  task update_partner: :environment do |t, args|
    Partner.all.each do |partner|
      partner.update_columns(slug: partner_uniq_slug(partner.name))
    end
  rescue StandardError => error
    puts "--- Error on MonthWisePaymentHistory creation due to: #{error}"
  end

  desc 'Task for slug adding in category'
  task update_category: :environment do |t, args|
    Category.all.each do |category|
      category.update_columns(slug: category_uniq_slug(category.title))
    end
  rescue StandardError => error
    puts "--- Error due to: #{error}"
  end

  def product_uniq_slug(title)
    slug = title.to_s.parameterize
    index = 0

    while Product.find_by(slug: slug)
      index += 1
      slug = "#{title.to_s.parameterize}-#{index}"
    end

    slug
  end

  def partner_uniq_slug(name)
    slug = name.to_s.parameterize
    index = 0

    while Partner.find_by(slug: slug)
      index += 1
      slug = "#{name.to_s.parameterize}-#{index}"
    end

    slug
  end

  def category_uniq_slug(title)
    slug = title.to_s.parameterize
    index = 0

    while Category.find_by(slug: slug)
      index += 1
      slug = "#{title.to_s.parameterize}-#{index}"
    end

    slug
  end
end
