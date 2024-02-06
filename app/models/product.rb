# frozen_string_literal: true

class Product < ApplicationRecord
  audited except: :sell_count
  include Sluggable
  include ProductCategoryList
  include ImageVersions
  include Rails.application.routes.url_helpers
  # include Ecommerce::V1::Helpers::ImageHelper

  attr_accessor :bundle_variants

  # has_many :line_items, dependent: :destroy
  has_many :assets
  has_many :options
  has_many :prices
  has_many :promotion_rules
  has_many :stock_items
  has_many :variants, dependent: :destroy
  has_many :suppliers_variants, through: :variants
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories
  has_many :frequently_asked_questions
  has_many :product_attribute_images
  has_many :product_attribute_values, through: :variants
  has_many :products_product_types, dependent: :destroy
  has_many :product_types, through: :products_product_types
  belongs_to :leaf_category, class_name: 'Category'
  belongs_to :root_category, class_name: 'Category', optional: true
  has_many :promotion_variants, dependent: :destroy
  has_many :promotions, through: :promotion_variants
  belongs_to :brand
  has_many :product_features, dependent: :destroy
  belongs_to :attribute_set, optional: true
  belongs_to :product_attribute, class_name: 'ProductAttribute', foreign_key: 'image_attribute_id', optional: true
  has_many :wishlists
  has_one :meta_datum, as: :metable, class_name: 'MetaDatum'
  has_many :shopoth_line_items, through: :variants
  belongs_to :staff, optional: true

  has_one_attached :main_image
  has_many_attached :images
  has_associated_audits
  validates :images, blob: { content_type: %w(image/jpg image/jpeg image/png image/webp),
                             size_range: 1..3.megabytes, }

  validates :main_image, attached: true, content_type: %w(image/png image/jpg image/jpeg image/webp),
            size: { less_than: 3.megabytes }

  validate :variants_sku, :check_tenures
  validate :attribute_set?, if: :creating_variable_product?
  validates :slug, uniqueness: true, presence: true
  validates :unique_id, uniqueness: true

  scope :publicly_visible, -> { where(public_visibility: true, is_deleted: false) }
  scope :not_deleted, -> { where(is_deleted: false) }

  def creating_variable_product?
    variable_product?
  end

  accepts_nested_attributes_for :variants,
                                reject_if: :all_blank,
                                allow_destroy: true,
                                update_only: true
  accepts_nested_attributes_for :frequently_asked_questions,
                                reject_if: :all_blank,
                                allow_destroy: true,
                                update_only: true
  accepts_nested_attributes_for :product_attribute_images,
                                reject_if: :all_blank,
                                allow_destroy: true,
                                update_only: true
  accepts_nested_attributes_for :product_features,
                                reject_if: :all_blank,
                                allow_destroy: true,
                                update_only: true
  accepts_nested_attributes_for :meta_datum, reject_if: :all_blank, allow_destroy: true

  STATUS = {
    new: 'new',
    modified: 'modified',
  }.freeze

  enum sku_type: { simple_product: 0, variable_product: 1, bundle_product: 2 }
  enum warranty_type: {
    no_warranty: 0,
    international_manufacturer_warranty: 1,
    non_local_warranty: 2,
    local_seller_warranty: 3,
    international_seller_warranty: 4,
  }
  enum business_type: {b2c: 0, b2b: 1, both: 2}

  serialize :configuration, Hash

  scope :b2b_products, ->{ where(business_type: [:b2b, :both]) }
  scope :b2c_products, ->{ where(business_type: [:b2c, :both]) }

  # scope :companies, -> {
  #   Product.all.map(&:company).uniq
  # }

  alias_method :hero_image, :main_image

  # after_create :agami_product_create
  before_create :assign_unique_id
  after_create :assign_bundle_variants
  after_save :remove_previous_images

  # update_index('products') { self }

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def assign_bundle_variants
    return unless bundle_product?

    fail StandardError, 'Need to provide bundle variants for bundle product.' unless bundle_variants.present?

    # First: Create bundle of bundle product's variant
    bundle = Bundle.create(variant: variants.first)

    # Second: Create bundle variants
    bundle_variants.each do |bundle_variant_param|
      bundle.bundle_variants.create(
        variant: Variant.find_by(sku: bundle_variant_param['bundle_sku']),
        quantity: bundle_variant_param['quantity'],
      )
    rescue StandardError => error
      # raise error
      puts "---Error assigning bundle variant : #{error.message}"
    end
  end

  include PgSearch::Model
  pg_search_scope :search_with_title, against: %i(title bn_title)

  def agami_product_create
    product = { product: ShopothWarehouse::V1::Entities::ExportProducts.represent(self) }
    AgamiProductCreateJob.perform_later(product.to_json)
  end

  def minimum_emrp
    variants.minimum(:effective_mrp) || 0
  end

  def min_emrp_variant
    @min_emrp_variant ||= variants.min_by(&:customer_effective_price)
  end

  def b2b_min_emrp_variant
    @b2b_min_emrp_variant ||= variants.min_by(&:b2b_effective_price)
  end

  def min_emrp_partner_variant(warehouse = nil)
    @min_emrp_partner_variant ||= if warehouse.present?
                                    variants.joins(:warehouse_variants).where('warehouse_variants.available_quantity > ? AND warehouse_variants.warehouse_id = ?', 0, warehouse.id).min_by(&:customer_effective_price)
                                  else
                                    variants.min_by(&:customer_effective_price)
                                  end
  end

  def b2b_min_emrp_partner_variant(warehouse = nil)
    @b2b_min_emrp_partner_variant ||= if warehouse.present?
                                    variants.joins(:warehouse_variants).where('warehouse_variants.available_quantity > ? AND warehouse_variants.warehouse_id = ?', 0, warehouse.id).min_by(&:b2b_effective_price)
                                  else
                                    variants.min_by(&:b2b_effective_price)
                                  end
  end

  def get_product_base_price
    min_emrp_variant&.price_consumer || 0
  end

  def b2b_get_product_base_price
    b2b_min_emrp_variant&.b2b_price || 0
  end

  def get_product_base_price_partner(warehouse = nil)
    min_emrp_partner_variant(warehouse)&.price_consumer || 0
  end

  def b2b_get_product_base_price_partner(warehouse = nil)
    b2b_min_emrp_partner_variant(warehouse)&.b2b_price || 0
  end

  def self.validate_tenures(tenures)
    return true if tenures.empty?

    tenure_array = Configuration.find_by(key: 'available_tenors')&.version_config&.values || []
    valid_tenures = tenures.map do |tenure|
      if tenure_array.include?(tenure)
        true
      else
        false
      end
    end

    valid_tenures.all?(true)
  end

  def product_title_downcase
    title.downcase
  end

  def discount
    min_emrp_variant&.fetch_discount || 0
  rescue => error
    Rails.logger.info("Error occurred calculating discount: #{error.message}")
    0
  end

  def b2b_discount
    b2b_min_emrp_variant&.fetch_b2b_discount || 0
  rescue => error
    Rails.logger.info("Error occurred calculating b2b discount: #{error.message}")
    0
  end

  def discount_stringify
    min_emrp_variant&.discount_stringify || '0 Tk'
  end

  def bn_discount_stringify
    min_emrp_variant&.bn_discount_stringify || '0 টাকা'
  end

  def discount_amount
    get_product_base_price * discount / 100
  end

  def discounted_price
    min_emrp_variant&.customer_effective_price || 0
  end

  def partner_discounted_price(warehouse = nil)
    min_emrp_partner_variant(warehouse)&.customer_effective_price || 0
  end

  def b2b_partner_discounted_price(warehouse = nil)
    b2b_min_emrp_partner_variant(warehouse)&.b2b_effective_price || 0
  end

  def product_available_quantity(warehouse)
    WarehouseVariant.where(warehouse: warehouse, variant_id: variants.ids)&.sum(:available_quantity) || 0
  end

  def self.products_sort(products, sort_by, brand_slug = '', min_price, max_price)
    products = if brand_slug.present? && min_price.present? && max_price.present?
                 products.joins(:variants, :brand).where(brands: { slug: brand_slug }).where(
                   'variants.effective_mrp >= ? AND variants.effective_mrp <= ?',
                   min_price, max_price
                 )
               elsif min_price.present? && max_price.present?
                 products.joins(:variants).where(
                   'variants.effective_mrp >= ? AND variants.effective_mrp <= ?', min_price, max_price
                 )
               elsif brand_slug.present?
                 products.joins(:brand).where(brands: { slug: brand_slug })
               else
                 products
               end

    if sort_by.present?
      case sort_by
      when 'featured'
        products.joins(:product_types).where('product_types.title = ?', 'Featured')
      when 'best_selling'
        products.order(sell_count: :desc)
      when 'low_to_high'
        products.sort_by(&:get_product_base_price)
      when 'high_to_low'
        products.sort_by(&:get_product_base_price).reverse
      when 'a_to_z'
        products.select('DISTINCT ON (lower(products.title)) *').order('lower(products.title) ASC')
      when 'z_to_a'
        products.select('DISTINCT ON (lower(products.title)) *').order('lower(products.title) DESC')
      when 'new_to_old'
        products.order(created_at: :desc)
      when 'old_to_new'
        products.order(created_at: :asc)
      else
        products
      end
    else
      products
    end
  end

  def self.sort(products, sort_column, direction, business_type = 'b2c')
    desc_direction = direction_desc? direction

    case sort_column
    when 'price'
      sorted_products = business_type == 'b2c' ? products.sort_by(&:get_product_base_price) : products.sort_by(&:b2b_get_product_base_price)
      desc_direction ? sorted_products.reverse : sorted_products
    else
      products
    end
  end

  def self.direction_desc?(direction)
    direction == 'desc'
  end

  def hero_image_file=(file)
    main_image.attach(
      io: file[:tempfile],
      filename: file[:filename],
      content_type: file[:type],
    )
  end

  def images_file=(file_arr)
    img_arr = []
    file_arr.each do |file|
      file_hash = {
        io: file[:tempfile],
        filename: file[:filename],
        content_type: file[:type],
      }
      img_arr << file_hash
    end
    self.images = img_arr
  end

  def self.get_img_url(image_variation, obj)
    Rails.application.routes.url_helpers.rails_representation_url(obj.variant(Product.sizes[image_variation.to_sym]).processed, only_path: true)
  end

  def master_img(image_size)
    main_image.variable? ? main_image.variant(Product.sizes[image_size.to_sym]).processed.service_url : main_image.service_url
  rescue StandardError => error
    nil
  end

  def self.search_by_title(val)
    if val
      where(['LOWER(title) LIKE ?', "%#{val.downcase}%"]).order('RANDOM()').limit(10)
    else
      all
    end
  end

  def self.search(val)
    if val
      Product.joins(:variants).where(
        ['LOWER(products.title) LIKE :key OR products.bn_title LIKE :key OR LOWER(variants.code_by_supplier) LIKE :key OR LOWER(variants.sku) LIKE :key', key: "%#{val.downcase}%"]
      )
    else
      all
    end
  end

  # @param [String] keyword: brand of the product
  def self.search_by_brands(keyword, products)
    products.joins(:brand).where(['LOWER(brands.name) LIKE ?', "%#{keyword.downcase}%"]).limit(10) if keyword
  end

  def self.filter(title, brand, category_id, sub_category_id, sku, business_type = nil)
    products = Product.unscoped.where(is_deleted: false)
    products = sku.present? ? products.joins(:variants).where(['LOWER(variants.sku) LIKE ?', "%#{sku.downcase}%"]) : products
    products = brand.present? ? products.joins(:brand).where(['LOWER(brands.name) LIKE ?', "%#{brand.downcase}%"]) : products

    products = products.where(['LOWER(title) LIKE ?', "%#{title.downcase}%"]) if title.present?
    category = category_id.present? ? Category.find_by(id: category_id.to_i) : nil
    sub_category = sub_category_id.present? ? Category.find_by(id: sub_category_id, parent_id: category&.id) : nil

    products = if sub_category.present?
                 products.filter_by_category(sub_category)
               else
                 category.present? ? products.filter_by_category(category) : products
               end

    if business_type.present?
      business_types = ['both'] << business_type
      products = products.where(business_type: business_types)
    end

    products.order(id: :desc).distinct
  end

  def self.filter_by_category(category)
    joins(:product_categories).where(product_categories: { category_id: category.id })
  end

  def self.to_csv
    require 'csv'
    headers = %w(product_id parent_category sub_category
                 sub_sub_category offer_type product_type title full_description
                 short_description warranty_period warranty_period_type warranty_policy
                 inside_box video_url warranty_type dangerous_goods sku_type
                 company brand certification license_required material consumption_guidelines
                 temperature_requirement keywords brand_message tagline va_sku va_weight
                 va_height va_width va_depth va_price_distribution va_price_retailer
                 va_price_consumer va_sku_case_dimension va_case_weight va_price_agami_trade
                 va_consumer_discount va_vat_tax va_effective_mrp va_moq va_sku_case_width
                 va_sku_case_length va_sku_case_height va_weight_unit va_height_unit va_width_unit
                 va_depth_unit va_sku_case_width_unit va_sku_case_length_unit va_sku_case_height_unit
                 va_case_weight_unit va_make_default fa_question_1 fa_answer_1 fa_question_2 fa_answer_2
                 fa_question_3 fa_answer_3 va_configuration main_image product_images)
    file_name = "products_#{Date.today}.csv"
    CSV.open("public/exported_files/#{file_name}", 'w', headers: true) do |csv|
      csv << headers # column names
      all.find_each do |product|
        category = product.show_category
        variant = product.variants.where(primary: true).first
        variant = variant.present? ? variant : product.variants.first
        faqs = product.frequently_asked_questions
        faq_1 = nil
        faq_2 = nil
        faq_3 = nil
        if faqs.present?
          faqs.each.with_index(1) do |faq, index|
            faq_1 = faq if index == 1
            faq_2 = faq if index == 2
            faq_3 = faq if index == 3
          end
        end
        va_attr_name_vals = variant.present? ? variant.product_attribute_values : nil
        va_configuration = {}
        if va_attr_name_vals.present?
          va_attr_name_vals.each do |product_attribute_value|
            product_attribute_name = product_attribute_value.product_attribute&.name
            va_configuration[product_attribute_name] = product_attribute_value.value
          end
        end
        main_image_url = product.main_image.attached? ? product.main_image.service_url : nil
        url_for_product_images = []
        if product.images.attached?
          product.images.each do |image|
            url_for_product_images << image.service_url
          end
        end

        csv << [product.id, category[:parent]&.title, category[:sub_category]&.title,
                category[:sub_sub_category]&.title, product.product_types&.pluck(:title)&.to_s.delete_prefix('[').delete_suffix(']'),
                product.product_type, product.title, product.description, product.short_description,
                product.warranty_period, product.warranty_period_type, product.warranty_policy, product.inside_box, product.video_url,
                product.warranty_type, product.dangerous_goods, product.sku_type, product.company, product.brand, product.certification,
                product.license_required, product.material, product.consumption_guidelines, product.temperature_requirement, product.keywords,
                product.brand_message, product.tagline, variant&.sku, variant&.weight, variant&.height,
                variant&.width, variant&.depth, variant&.price_distribution, variant&.price_retailer,
                variant&.price_consumer, variant&.sku_case_dimension, variant&.case_weight, variant&.price_agami_trade,
                variant&.consumer_discount, variant&.vat_tax, variant&.effective_mrp, variant&.moq,
                variant&.sku_case_width, variant&.sku_case_length, variant&.sku_case_height, variant&.weight_unit,
                variant&.height_unit, variant&.width_unit, variant&.depth_unit, variant&.sku_case_width_unit,
                variant&.sku_case_length_unit, variant&.sku_case_height_unit, variant&.case_weight_unit,
                variant&.primary, faq_1&.question, faq_1&.answer, faq_2&.question, faq_2&.answer, faq_3&.question,
                faq_3&.answer, va_configuration&.to_s.delete_prefix('[').delete_suffix(']'), main_image_url, url_for_product_images&.to_s.delete_prefix('[').delete_suffix(']'),]
      end
    end
    file_name
  end

  def self.get_product(slug)
    Product.publicly_visible.find_by(slug: slug)
  end

  def show_category
    cat = {}
    parent = categories.where(parent_id: nil)&.first
    cat[:parent] = parent
    sub_category = parent.present? ? categories.where(parent_id: parent.id)&.first : nil
    cat[:sub_category] = sub_category
    sub_sub_category = sub_category.present? ? categories.where(parent_id: sub_category.id)&.first : nil
    cat[:sub_sub_category] = sub_sub_category
    cat
  end

  def variants_sku
    skus = variants.map(&:sku)
    errors.add(:base, 'SKU has been taken') unless skus & skus == skus
  end

  def check_tenures
    return if tenures.is_a?(Array) && Product.validate_tenures(tenures)

    errors.add(:base, 'Please select valid tenures.')
  end

  def attribute_set?
    errors.add(:base, 'Attribute set must exist ') unless attribute_set_id.present?
  end

  def get_app_img(size)
    hero_image.present? ? hero_image.variant(Product.sizes[size.to_sym]).processed.service_url : nil
  rescue => ex
    "Unable to get product hero image! Reason: #{ex}"
  end

  def promo_tag
    featured_product_type = product_types.where(title: Product::PRODUCT_TYPES[:featured]).first
    new_product_type = product_types.where(title: Product::PRODUCT_TYPES[:new_arrival]).first

    return '0% EMI' if is_emi_available
    return "#{discount_stringify} Discount" if discount.to_i.positive?
    return 'Featured' if product_types.include? featured_product_type
    return 'New' if product_types.include? new_product_type

    ''
  end

  def bn_promo_tag
    featured_product_type = product_types.where(title: Product::PRODUCT_TYPES[:featured]).first
    new_product_type = product_types.where(title: Product::PRODUCT_TYPES[:new_arrival]).first

    return '০% ইএমআই' if is_emi_available
    return "#{bn_discount_stringify} ছাড়" if discount.to_i.positive?
    return 'বৈশিষ্ট্যযুক্ত' if product_types.include? featured_product_type
    return 'নতুন' if product_types.include? new_product_type

    ''
  end

  def remove_previous_images
    return unless variable_product?
    return unless saved_change_to_image_attribute_id?

    product_attribute_value_ids = product_attribute.product_attribute_values.map(&:id)
    product_attribute_images.where.not(product_attribute_value_id: product_attribute_value_ids).delete_all
  end

  def attribute_value_images
    return [] unless creating_variable_product?

    product_attribute&.product_attribute_values&.map do |product_attribute_value|
      {
        product_attribute_value_id: product_attribute_value.id,
        value: product_attribute_value.value,
        images: product_attribute_value.product_attribute_images&.where(product_id: id)&.last&.images&.map do |image|
          {
            id: image.id,
            image: image_path_for_attachment(image),
          }
        end,
      }
    end
  end

  # This method is only for ECOM: Product Details.
  def attribute_images
    return [] unless creating_variable_product?

    product_attribute&.product_attribute_values&.map do |product_attribute_value|
      {
        product_attribute_value_id: product_attribute_value.id,
        value: product_attribute_value.value,
        images: product_attribute_value.product_attribute_images&.where(product_id: id)&.last&.images&.map do |image|
          {
            id: image.id,
            small_img: image&.variant(Product.sizes[:product_small])&.processed&.service_url,
            medium_img: image&.variant(Product.sizes[:product_medium])&.processed&.service_url,
            large_img: image&.variant(Product.sizes[:product_large])&.processed&.service_url,
          }
        rescue
          {
            id: nil,
            small_img: '',
            medium_img: '',
            large_img: '',
          }
        end,
      }
    end
  end

  def image_path_for_attachment(image)
    begin
      image.service_url if image.present?
    rescue => _ex
      nil
    end
  end

  def get_reviews
    Review.approved.variant_reviews.where(reviewable_id: variants.ids)
  end

  def record_visited(request_ip, current_user)
    key = current_user.present? ? current_user&.id : request_ip
    product_list = Rails.cache.fetch("products-visited-by-#{key}") || {}
    count = product_list[:"#{id}"].to_i
    product_list[:"#{id}"] = count + 1
    product_list = product_list.sort_by { |_key, value| value }.reverse.to_h
    Rails.cache.write("products-visited-by-#{key}", product_list)
  rescue => error
    Rails.logger.info("Error while record product visit count: #{error.message}")
  end

  def validate_products_max_limit(shopoth_line_items, add_quantity)
    products_cart_quantity = shopoth_line_items.where(variant_id: variants.ids).sum(:quantity) || 0
    if max_quantity_per_order.blank? || (products_cart_quantity + add_quantity) <= max_quantity_per_order.to_i
      return { success: true }
    end

    { success: false }
  end

  def assign_unique_id
    self.unique_id = SecureRandom.uuid unless unique_id.present?
  end

  # private
  #
  # def slug_candidates
  #   # **********************************************
  #   # Don't fix robocop error. Else code won't work.
  #   # **********************************************
  #   [:title, [:title, :id_for_slug]]
  # end
  #
  # def id_for_slug
  #   Product.where('LOWER(products.title) = ?', title.downcase).count
  # end
end
