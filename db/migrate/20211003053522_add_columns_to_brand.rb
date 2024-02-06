class AddColumnsToBrand < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :branding_layout, :integer, default: 0
    add_column :brands, :branding_promotion_with, :integer, default: 0
    add_column :brands, :branding_video_url, :string
    add_column :brands, :branding_title, :string
    add_column :brands, :branding_title_bn, :string
    add_column :brands, :branding_subtitle, :string
    add_column :brands, :branding_subtitle_bn, :string
    add_column :brands, :short_description, :string
    add_column :brands, :short_description_bn, :string
    add_column :brands, :more_info_button_text, :string
    add_column :brands, :more_info_button_text_bn, :string
    add_column :brands, :more_info_url, :string
  end
end
