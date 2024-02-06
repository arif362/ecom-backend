class Category < ApplicationRecord
  audited
  include Sluggable
  include ImageVersions

  belongs_to :parent, class_name: 'Category', optional: true
  belongs_to :staff, optional: true
  has_many :sub_categories, class_name: 'Category', foreign_key: :parent_id, dependent: :destroy
  has_many :products
  has_many :questionnaires
  has_many :product_categories, dependent: :destroy
  has_many :products, through: :product_categories
  has_one :meta_datum, as: :metable, class_name: 'MetaDatum'
  has_many :promo_coupon_rules, as: :ruleable, class_name: 'PromoCouponRule', dependent: :destroy
  has_many :promo_coupons, through: :promo_coupon_rules

  has_one_attached :image
  has_one_attached :banner_image

  validates :title, :bn_title, presence: true
  validates :slug, uniqueness: true, presence: true
  validates :image, :banner_image, blob: { content_type: %w(image/jpg image/jpeg image/png image/webp),
                                           size_range: 1..3.megabytes, }, on: :save
  validates :unique_id, uniqueness: true

  accepts_nested_attributes_for :meta_datum, reject_if: :all_blank, allow_destroy: true

  enum business_type: { b2c: 0, b2b: 1, both: 2 }

  scope :trending_products, -> { where(title: 'trending').joins(:products) }
  scope :new_products, -> { where(title: 'new').joins(:products) }
  scope :best_selling, -> { where(title: 'best selling').joins(:products) }
  scope :visible_categories, -> { where(home_page_visibility: true) }
  scope :b2b_categories, ->{ where(business_type: [:b2b, :both]) }
  scope :b2c_categories, ->{ where(business_type: [:b2c, :both]) }

  before_create :assign_unique_id, :call_3ps_create_api
  before_update :call_3ps_update_api
  before_destroy :call_3ps_delete_api

  # TODO: Eta call kora lagbe to with proper size to get the image
  def get_app_img(size)
    image.present? ? image.variant(Category.sizes[size.to_sym]).processed.service_url : nil
  rescue => ex
    "Unable to get image. Reason: #{ex}"
  end

  def siblings
    Category.where(parent_id: parent_id, home_page_visibility: true)
  end

  def pick_parent
    return self unless parent.present?

    parent.pick_parent
  end

  def add_bread_crumbs(bread_crumbs)
    bread_crumbs << self
    return bread_crumbs.reverse unless parent.present?

    parent.add_bread_crumbs(bread_crumbs)
  end

  def self.fetch_parent_category(category)
    category = category.parent until category.parent_id.nil?
    category.id
  end

  def image_file=(file)
    image.attach(
      io: file[:tempfile],
      filename: file[:filename],
      content_type: file[:type],
    )
  end

  def banner_image_file=(file)
    banner_image.attach(
      io: file[:tempfile],
      filename: file[:filename],
      content_type: file[:type],
    )
  end

  def update_product_categories(parent_category, new_parent_category)
    products = self.products
    old_parents = fetch_parents(parent_category)
    new_parents = fetch_parents(new_parent_category)
    update!(parent: new_parent_category)
    product_categories = ProductCategory.where(product_id: products.ids, category_id: old_parents)
    product_categories.delete_all
    result = []
    products.each do |product|
      new_parents.each do |parent|
        prod_cat = { product_id: product.id, category_id: parent }
        result.push(prod_cat)
      end
    end
    ProductCategory.create!(result)
  end

  private

  def fetch_parents(category)
    parent_categories = []
    until category.nil?
      parent_categories.push(category.id)
      category = category.parent
    end
    parent_categories
  end

  def assign_unique_id
    self.unique_id = SecureRandom.uuid
  end

  def call_3ps_create_api
    response = Thanos::Category.create(self)
    return unless response[:error].present?

    e = errors.add(:base, (response[:error_descrip]).to_s)
    fail StandardError, e.to_s
  end

  def call_3ps_update_api
    response = Thanos::Category.update(self)
    return unless response[:error].present?

    e = errors.add(:base, (response[:error_descrip]).to_s)
    fail StandardError, e.to_s
  end

  def call_3ps_delete_api
    response = Thanos::Category.delete(self)
    return unless response[:error].present?

    e = errors.add(:base, (response[:error_descrip]).to_s)
    fail StandardError, e.to_s
  end
end
