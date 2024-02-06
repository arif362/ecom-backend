require 'util'
class Variant < ApplicationRecord
  audited
  extend Util
  belongs_to :product
  belongs_to :staff, optional: true
  has_many :product_attribute_values_variants, dependent: :destroy
  has_many :product_attribute_values, through: :product_attribute_values_variants
  has_many :failed_qcs
  has_many :shopoth_line_items, dependent: :nullify
  has_many :warehouse_variants
  has_many :warehouses, through: :warehouse_variants
  has_many :storage_variants
  has_many :suppliers_variants, dependent: :destroy
  has_many :suppliers, through: :suppliers_variants
  # has_many :supplier_variant_values, dependent: :destroy
  has_many :locations, through: :warehouse_variants
  has_many :warehouse_variants_locations, through: :warehouse_variants
  has_many :line_items
  has_many :promotion_variants, dependent: :destroy
  has_many :promotions, through: :promotion_variants
  has_many :blocked_items
  has_many :stock_changes
  has_many :reviews, as: :reviewable, dependent: :destroy
  has_many :requested_variants, dependent: :destroy
  has_one :bundle, dependent: :destroy
  has_many :bundle_variants, dependent: :destroy
  has_many :bundles, through: :bundle_variants
  has_many :stock_changes, as: :stock_changeable
  has_many :promo_coupon_rules, as: :ruleable, class_name: 'PromoCouponRule', dependent: :destroy
  has_many :promo_coupons, through: :promo_coupon_rules
  delegate :brand, to: :product, allow_nil: true
  has_many :supplier_variant_changes

  validates_uniqueness_of :sku, :unique_id
  validates :price_consumer, presence: true
  validates :discount_type, presence: true, if: -> {product&.b2c? || product&.both?}
  validates :b2b_discount_type, :b2b_price, presence: true, if: -> {product&.b2b? || product&.both?}
  validates :b2b_price, :b2b_discount, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
  validate :discount_cannot_be_greater_than_price

  # enumerable
  enum discount_type: { percentage: 0, fixed: 1 }, _suffix: 'discount'
  enum b2b_discount_type: { percentage: 0, fixed: 1 }, _suffix: 'discount', _prefix: 'b2b'
  enum bundle_status: { packed: 0, unpacked: 1 }

  serialize :configuration, Hash

  before_create :assign_unique_id
  before_save :deleted_check, :assign_price
  default_scope { where(is_deleted: false) }

  def discount_cannot_be_greater_than_price
    case product&.business_type
    when 'b2c', 'both'
      if percentage_discount?
        errors.add(:consumer_discount, 'can not be greater than 100') if consumer_discount > 100
      else
        errors.add(:consumer_discount, 'can not be greater than consumer price') if consumer_discount > price_consumer
      end
    when 'b2b', 'both'
      if b2b_percentage_discount?
        errors.add(:b2b_discount, 'can not be greater than 100') if b2b_discount > 100
      else
        errors.add(:b2b_discount, 'can not be greater than b2b price') if b2b_discount > b2b_price
      end
    end
  end

  scope :filter_with, -> (warehouse_id='', company='', category_id='', sub_category_id='') {
    sql = ''
    params = {}

    if warehouse_id.present?
      sql = "warehouses.id = :warehouse_id"
      params[:warehouse_id] = warehouse_id
    end

    if company.present?
      sql = "products.company = :company"
      params[:company] = company
    end

    if category_id.present?
      sql = "categories.id = :category_id"
      params[:category_id] = category_id
    end

    # if sub_category_id.present?
    #  sql = "categories.id = :category_id"
    #  params[:category_id] = category_id
    # end

    join_sql = <<SQL
LEFT JOIN warehouse_variants ON warehouse_variants.variant_id = variants.id
LEFT JOIN warehouses ON warehouse_variants.warehouse_id = warehouses.id
LEFT JOIN products ON variants.product_id = products.id
LEFT JOIN product_categories ON product_categories.product_id = products.id
LEFT JOIN categories ON categories.id = product_categories.category_id
SQL
    Variant.joins(join_sql).where(sql,params)
    # Variant.joins('LEFT JOIN products ON variants.product_id = products.id LEFT JOIN product_categories pc on pc.product_id = products.id LEFT JOIN categories ON categories.id = product_categories.category_id').where('products.company = ? AND categories.id = ?', 'BATB', 59)
  }

  scope :filter_by, -> (variants=nil, company='', category_id='', sub_category_id='', sku='', product_title='') {

    sql = ''
    sql_params = {}

    # if company.present?
    #   sql += "products.company = :company"
    #   sql_params[:company] = company
    # end

    if company.present?
      sql += "LOWER(products.company) LIKE :company"
      sql_params[:company] = "%#{company.downcase}%"
    end

    if category_id.present?
      if sub_category_id.present?
        category = Category.find_by(id: sub_category_id)
        if category&.parent_id == category_id.to_i
          sql += sql_conjunction('AND', sql, 'categories.id = :category_id')
          sql_params[:category_id] = sub_category_id
        end
      else
        sql += sql_conjunction('AND', sql, 'categories.id = :category_id')
        sql_params[:category_id] = category_id
      end
    end

    if sku.present?
      sql += sql_conjunction('AND', sql, 'variants.sku = :sku')
      sql_params[:sku] = sku
    end

    variants = if variants.nil?
                 Variant.left_joins([{ product: :categories }, :warehouse_variants]).where(sql, sql_params).uniq
               else
                 variants.left_joins([{ product: :categories }]).where(sql, sql_params).uniq
               end

    if product_title.present?
      product_ids = Product.unscoped.where("LOWER(products.title) LIKE '%#{product_title.downcase}%'").ids
      variants.select { |v| product_ids.include?(v.product_id) }
    else
      variants
    end
  }

  def deleted_check
    self.deleted_at = Time.now if is_deleted
  end

  def assign_price
    self.consumer_discount = 0 unless consumer_discount.present?
    self.price_consumer = price_consumer.to_i
    self.effective_mrp = consumer_final_price
    self.b2b_effective_mrp = b2b_final_price if product&.b2b? || product&.both?
    self.price_retailer = consumer_final_price
    self.price_agami_trade = consumer_final_price
    self.price_distribution = consumer_final_price
  end

  def self.search_by_sku(val = '')
    where('sku LIKE ?', "%#{val}%").limit(25)
  end

  def consumer_discount_amount
    return 0 unless consumer_discount

    if percentage_discount?
      price_consumer * consumer_discount / 100
    else
      consumer_discount
    end
  end

  def b2b_discount_amount
    return 0 unless b2b_discount

    if b2b_percentage_discount?
      b2b_price * b2b_discount / 100
    else
      b2b_discount
    end
  end

  def promotional_discount_amount
    @promotional_discount_amount ||= promotion_variants.joins(:promotion).
                                     where("CONCAT(from_date, ' ', start_time)::timestamp AT TIME ZONE 'Asia/Dhaka' <= :today
    AND CONCAT(to_date, ' ', end_time)::timestamp AT TIME ZONE 'Asia/Dhaka' >= :today AND promotions.is_active=true",
                                           today: Time.now.in_time_zone('Asia/Dhaka')).
                                     maximum('promotion_variants.promotional_discount') || 0
  end

  def final_discount(business_type = 'b2c')
    if business_type == 'b2b'
      [b2b_discount_amount, promotional_discount_amount].max
    else
      [consumer_discount_amount, promotional_discount_amount].max
    end
  end

  def consumer_final_price
    (price_consumer - consumer_discount_amount).ceil(0)
  end

  def b2b_final_price
    (b2b_price - b2b_discount_amount).ceil(0)
  end

  def customer_effective_price
    (price_consumer - final_discount).ceil(0)
  end

  def b2b_effective_price
    (b2b_price - final_discount('b2b')).ceil(0)
  end

  def fetch_discount
    c_discount = percentage_discount? ? consumer_discount.truncate(1) : consumer_discount.to_f
    consumer_discount_amount > promotional_discount_amount ? c_discount : promotional_discount_amount.to_i
  end

  def fetch_b2b_discount
    c_discount = b2b_percentage_discount? ? b2b_discount.truncate(1) : b2b_discount.to_f
    b2b_discount_amount > promotional_discount_amount ? c_discount : promotional_discount_amount.to_i
  end

  def discount_stringify
    discount = fetch_discount.to_i
    if promotional_discount_amount > consumer_discount_amount
      "#{discount} Tk"
    else
      percentage_discount? ? "#{discount} %" : "#{discount} Tk"
    end
  end

  def bn_discount_stringify
    discount = fetch_discount.to_i.to_s.to_bn
    if promotional_discount_amount > consumer_discount_amount
      "#{discount} টাকা"
    else
      percentage_discount? ? "#{discount} %" : "#{discount} টাকা"
    end
  end

  def get_badge
    featured_product_type = product.product_types.where(title: Product::PRODUCT_TYPES[:featured]).first
    new_product_type = product.product_types.where(title: Product::PRODUCT_TYPES[:new_arrival]).first

    return '0% EMI' if product.is_emi_available
    return "#{discount_stringify} Discount" if fetch_discount.to_i.positive?
    return 'Featured' if product.product_types.include? featured_product_type
    return 'New' if product.product_types.include? new_product_type

    ''
  end

  def get_bn_badge
    featured_product_type = product.product_types.find_by(title: Product::PRODUCT_TYPES[:featured])
    new_product_type = product.product_types.find_by(title: Product::PRODUCT_TYPES[:new_arrival])

    return '০% ইএমআই' if product.is_emi_available
    return "#{bn_discount_stringify} ছাড়" if fetch_discount.to_i.positive?
    return 'বৈশিষ্ট্যযুক্ত' if product.product_types.include? featured_product_type
    return 'নতুন' if product.product_types.include? new_product_type

    ''
  end

  def self.to_csv(variants, warehouse)
    require 'csv'
    if warehouse.warehouse_type == Warehouse::WAREHOUSE_TYPES[:central]
      headers = %w(id product_title packed price_agami_trade effective_mrp total_count fc price_distribution in_transit)
      file_name = "variants_#{Date.today}.csv"

      CSV.open("public/exported_files/#{file_name}", 'w', headers: true) do |csv|
        csv << headers # column names

        variants.each do |variant|
          csv << [
            variant[:id],
            variant[:product_title],
            variant[:packed],
            variant[:price_agami_trade],
            variant[:effective_mrp],
            variant[:total_count],
            variant[:fc],
            variant[:price_distribution],
            variant[:in_transit],
          ]
        end
      end
    elsif warehouse.warehouse_type == Warehouse::WAREHOUSE_TYPES[:distribution] || warehouse.warehouse_type == Warehouse::WAREHOUSE_TYPES[:member] ||
      warehouse.warehouse_type == Warehouse::WAREHOUSE_TYPES[:b2b]
      headers = %w(id product_title packed effective_mrp total_count fc price_distribution in_transit)
      file_name = "variants_#{Date.today}.csv"

      CSV.open("public/exported_files/#{file_name}", 'w', headers: true) do |csv|
        csv << headers # column names

        variants.each do |variant|
          csv << [
            variant[:id],
            variant[:product_title],
            variant[:packed],
            variant[:effective_mrp],
            variant[:total_count],
            variant[:fc],
            variant[:price_distribution],
            variant[:in_transit],
          ]
        end
      end
    end
    file_name
  end

  def self.search_by_sku_or_supplier_code(search_string = '', order_type = '', warehouse_id = '')
    case order_type
    when 'sto'
      where(['LOWER(variants.sku) LIKE :key OR LOWER(variants.code_by_supplier) LIKE :key',
             { key: "%#{search_string}%" },])
    when 'rto'
      if warehouse_id.present?
        joins(:warehouse_variants).where(
          'warehouse_variants.warehouse_id = ? And warehouse_variants.available_quantity > 0', warehouse_id
        ).where(product_id: Product.unscoped.where(is_deleted: false).ids).where(
          ['LOWER(variants.sku) LIKE :key OR LOWER(variants.code_by_supplier) LIKE :key', { key: "%#{search_string}%" },],
        ).distinct
      end
    else
      where(['LOWER(variants.sku) LIKE :key OR LOWER(variants.code_by_supplier) LIKE :key',
             { key: "%#{search_string}%" },]).
        where('variants.product_id In (?)', Product.unscoped.where(sku_type: %w(simple_product variable_product), is_deleted: false).ids)
    end
  end

  def self.bundle_sku_search(search_string = '', product_ids)
    where(['LOWER(variants.sku) LIKE :key', { key: "%#{search_string}%" }]).where(product_id: product_ids)
  end

  def warehouse_variant(warehouse)
    warehouse_variants.find_by(warehouse_id: warehouse.id)
  end

  def wishlisted?(current_user)
    current_user.present? && current_user.wishlists&.find_by(product_id: product_id).present?
  end

  def is_requested?(current_user, warehouse)
    current_user.present? && current_user.requested_variants&.find_by(variant_id: id, warehouse: warehouse).present?
  end

  def available_quantity(warehouse)
    return 0 unless warehouse.present?

    warehouse_variants.find_by(warehouse: warehouse)&.available_quantity.to_i
  end

  def self.get_variants(products)
    where(product_id: products.ids)
  end

  def leaf_category_id
    product.leaf_category_id
  end

  def brand_id
    product&.brand_id
  end

  def tenures
    product&.tenures || []
  end

  def emi_available?
    product&.is_emi_available || false
  end

  def assign_unique_id
    self.unique_id = SecureRandom.uuid unless unique_id.present?
  end
end
