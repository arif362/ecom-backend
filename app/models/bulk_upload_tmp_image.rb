class BulkUploadTmpImage < ApplicationRecord
  has_one_attached :image

  validates :file_name, presence: true, uniqueness: true
  validates :image, blob: { content_type: %w(image/jpg image/jpeg image/png), size_range: 1..3.megabytes }

  def self.add_image(uploaded_files)
    tmp_saved_image_list = []
    uploaded_files.each do |image|
      if BulkUploadTmpImage.find_by(file_name: image['filename']).blank?
        bulk_upload_tmp_image = BulkUploadTmpImage.create!(image_file: image, file_name: image['filename'])
        tmp_saved_image_list << bulk_upload_tmp_image
      end
    end
    tmp_saved_image_list
  end

  def image_file=(file)
    self.image.attach(
      io: file[:tempfile],
      filename: file[:filename],
      content_type: file[:type]
    )
  end

end
