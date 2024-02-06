class AddAttributesToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :uid, :string, null: false, default: ""
    add_column :products, :bn_uid, :string, null: false, default: ""
    add_column :products, :source, :string, null: false, default: ""
    add_column :products, :bn_source, :string, null: false, default: ""
    add_column :products, :company, :string, null: false, default: ""
    add_column :products, :bn_company, :string, null: false, default: ""
    add_column :products, :brand, :string, null: false, default: ""
    add_column :products, :bn_brand, :string, null: false, default: ""
    add_column :products, :certification, :string
    add_column :products, :bn_certification, :string
    add_column :products, :license_required, :string
    add_column :products, :bn_license_required, :string
    add_column :products, :company_category, :string
    add_column :products, :po_name, :string, null: false, default: ""
    add_column :products, :bn_po_name, :string, null: false, default: ""
    add_column :products, :product, :string, null: false, default: ""
    add_column :products, :bn_product, :string, null: false, default: ""
    add_column :products, :product_variant, :string, null: false, default: ""
    add_column :products, :material, :string
    add_column :products, :bn_material, :string
    add_column :products, :broad_description, :text
    add_column :products, :bn_broad_description, :text
    add_column :products, :details, :text, null: false, default: ""
    add_column :products, :bn_details, :text, null: false, default: ""
    add_column :products, :consumption_guidelines, :text
    add_column :products, :bn_consumption_guidelines, :text
    add_column :products, :additional_information, :text
    add_column :products, :bn_additional_information, :text
    add_column :products, :temperature_requirement, :string, null: false, default: ""
    add_column :products, :bn_temperature_requirement, :string, null: false, default: ""
    add_column :products, :fragility, :string, null: false, default: ""
    add_column :products, :bn_fragility, :string, null: false, default: ""
    add_column :products, :segment, :string, null: false, default: ""
    add_column :products, :specific_product_lead_time, :string, null: false, default: ""
    add_column :products, :avaialability, :string, null: false, default: ""
    add_column :products, :keywords, :string
    add_column :products, :brand_message, :text
    add_column :products, :tagline, :text
    add_column :products, :hero_image, :string, null: false, default: ""
    add_column :products, :images, :string
  end
end
