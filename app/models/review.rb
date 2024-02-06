class Review < ApplicationRecord
  ##############################
  # ASSOCIATION
  #############################
  belongs_to :reviewable, polymorphic: true
  belongs_to :shopoth_line_item, optional: true
  belongs_to :customer_order, optional: true
  belongs_to :user
  has_many_attached :images

  ############################
  # VALIDATION
  ############################
  validates :title, presence: true
  validates :rating, inclusion: 0..5
  validates :images, blob: { content_type: %w(image/jpg image/jpeg image/png image/webp), size_range: 1..5.megabytes }

  scope :approved, -> { where(is_approved: true) }
  scope :variant_reviews, -> { where(reviewable_type: 'Variant') }
  scope :partner_reviews, -> { where(reviewable_type: 'Partner') }

  def self.comments
    approved.pluck(:description)&.reject(&:blank?)
  end

  def images_file=(file_arr)
    img_arr = []
    file_arr&.each do |file|
      file_hash = {
        io: file[:tempfile],
        filename: file[:filename],
        content_type: file[:type],
      }
      img_arr << file_hash
    end
    self.images = img_arr
  end
end
