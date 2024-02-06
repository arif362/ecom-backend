class ProductAttributeImage < ApplicationRecord
  belongs_to :product
  belongs_to :product_attribute_value

  has_many_attached :images
  validates :images, blob: { content_type: %w(image/jpg image/jpeg image/png image/webp), size_range: 1..3.megabytes }

  default_scope { where(is_deleted: false) }

  def images_file=(file_arr)
    img_arr = []
    file_arr.each do |file|
      file_hash = {
       io: file[:tempfile],
       filename: file[:filename],
       content_type: file[:type]
      }
      img_arr << file_hash
    end
    self.images = img_arr
  end
end
