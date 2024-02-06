class BannerImage < ApplicationRecord
  #############################
  ####### Association #########
  #############################
  belongs_to :promo_banner
  has_one_attached :image

  enum image_type: { app: 0, web: 1 }

  #############################
  ####### Validation ##########
  #############################
  validates :image, attached: true, content_type: %w(image/png image/jpg image/jpeg image/webp), size: { less_than: 5.megabytes }

  def image_file=(file)
    image.attach(
      io: file[:tempfile],
      filename: file[:filename],
      content_type: file[:type],
    )
  end
end
