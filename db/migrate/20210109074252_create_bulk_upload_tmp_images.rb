class CreateBulkUploadTmpImages < ActiveRecord::Migration[6.0]
  def change
    create_table :bulk_upload_tmp_images do |t|
      t.string :file_name

      t.timestamps
    end
    add_index :bulk_upload_tmp_images, :file_name, unique: true
  end
end
