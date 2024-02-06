class Slide < ApplicationRecord
  audited
  include ImageVersions
  include Rails.application.routes.url_helpers

  enum img_type: { homepage_slider: 0, promotional_slider: 1, selection_slider: 2, category_page_slider: 3, 
                   search_page_slider: 4, app_coupon_slider: 5, web_coupon_slider: 6, }

  scope :published, -> { where(published: true) }
  scope :all_homepage_slider_images, -> { published.where(img_type: Slide.img_types[:homepage_slider]).reorder(:position, updated_at: :asc) }
  scope :all_promotional_slider_images, -> { published.where(img_type: Slide.img_types[:promotional_slider]).reorder(:position, updated_at: :asc) }
  scope :all_selection_slider_images, -> { published.where(img_type: Slide.img_types[:selection_slider]).reorder(:position, updated_at: :asc) }
  scope :all_category_page_slider_images, -> { published.where(img_type: Slide.img_types[:category_page_slider]).reorder(:position, updated_at: :asc) }
  scope :all_search_page_slider_images, -> { published.where(img_type: Slide.img_types[:search_page_slider]).reorder(:position, updated_at: :asc) }
  scope :all_app_coupon_slider_images, -> { published.where(img_type: Slide.img_types[:app_coupon_slider]).reorder(:position, updated_at: :asc) }
  scope :all_web_coupon_slider_images, -> { published.where(img_type: Slide.img_types[:web_coupon_slider]).reorder(:position, updated_at: :asc) }

  has_one_attached :image
  belongs_to :product, touch: true, optional: true

  validates :name, :image, presence: true

  validates :image, attached: true, content_type: %w(image/png image/jpg image/jpeg image/webp),
                    size: { less_than: 5.megabytes }

  default_scope { order('id DESC') }

  def get_image_type_value
    Slide.img_types["#{img_type}"]
  end

  def attachment(file)
    image.attach(
      io: file[:tempfile],
      filename: file[:filename],
      content_type: file[:type],
    )
  end
end
