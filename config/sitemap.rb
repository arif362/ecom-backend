require 'aws-sdk-s3'
# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = ENV['ROOT_URL']
SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(ENV['AWS_S3_BUCKET'],
                                                                        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                                                                        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
                                                                        aws_region: ENV['AWS_S3_REGION']
)

# SitemapGenerator::Sitemap.sitemaps_host = "http://s3.#{ENV["AWS_S3_REGION"]}.amazonaws.com/#{ENV["AWS_S3_BUCKET"]}"
SitemapGenerator::Sitemap.sitemaps_host = ENV['ROOT_URL']
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.create_index = :auto

Rails.logger.info 'Sitemap refresh starting...............................'
p 'Sitemap refresh starting...............................'

SitemapGenerator::Sitemap.create(compress: false) do

  group(filename: :products, compress: false) do
    Product.find_each do |product|
      add "#{product.slug}", lastmod: product.updated_at
    end
  end

  group(filename: :categories, compress: false) do
    Category.find_each do |category|
      add "#{category.slug}", lastmod: category.updated_at
    end
  end

  group(filename: :brands, compress: false) do
    Brand.find_each do |brand|
      add "#{brand.slug}", lastmod: brand.updated_at
    end
  end

  group(filename: :help, compress: false) do
    Article.find_each do |article|
      add "#{article.slug}", lastmod: article.updated_at
    end
    add '/contact-us'
  end

  group(filename: :local_stores, compress: false) do
    Partner.find_each do |partner|
      add "#{partner.slug}", lastmod: partner.updated_at
    end
  end
end

Rails.logger.info 'Sitemap refresh end...............................'
p 'Sitemap refresh end...............................'


