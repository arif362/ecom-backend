# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_12_04_045743) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.integer "district_id", null: false
    t.integer "thana_id", null: false
    t.integer "area_id", null: false
    t.string "name"
    t.string "bn_name"
    t.string "address_line", null: false
    t.string "bn_address_line"
    t.string "zip_code"
    t.string "phone"
    t.string "bn_phone"
    t.string "alternative_phone"
    t.string "bn_alternative_phone"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "addressable_id"
    t.string "addressable_type"
    t.bigint "user_id"
    t.boolean "default_address", default: false
    t.string "title", default: "others"
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "aggregate_returns", force: :cascade do |t|
    t.decimal "sub_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "grand_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "pick_up_charge", precision: 10, scale: 2, default: "0.0"
    t.boolean "refunded", default: false
    t.bigint "customer_order_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "warehouse_id"
    t.integer "rider_id"
    t.datetime "reschedule_date"
    t.decimal "vat_shipping_charge", precision: 8, scale: 2, default: "0.0"
    t.integer "distributor_id"
    t.index ["customer_order_id"], name: "index_aggregate_returns_on_customer_order_id"
  end

  create_table "aggregated_payment_customer_orders", force: :cascade do |t|
    t.integer "aggregated_payment_id", null: false
    t.integer "customer_order_id", null: false
    t.integer "amount", null: false
    t.integer "payment_type", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "aggregated_payments", force: :cascade do |t|
    t.integer "payment_type", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "month", default: 0
    t.integer "year"
    t.integer "partner_schedule", default: 0
    t.integer "received_by_id"
    t.string "received_by_type"
  end

  create_table "aggregated_transaction_customer_orders", force: :cascade do |t|
    t.integer "aggregated_transaction_id", null: false
    t.integer "customer_order_id", null: false
    t.integer "amount", null: false
    t.integer "transaction_type", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "aggregated_transactions", force: :cascade do |t|
    t.integer "transaction_type", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "month", default: 0
    t.integer "year"
    t.float "total_amount", default: 0.0
    t.float "adjustment_amount", default: 0.0
    t.float "transactional_amount", default: 0.0
  end

  create_table "ambassadors", force: :cascade do |t|
    t.bigint "user_id"
    t.string "bkash_number"
    t.string "preferred_name"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "app_configs", force: :cascade do |t|
    t.string "fcm_token"
    t.string "latest_app_version"
    t.boolean "force_update", default: false
    t.string "registrable_type", null: false
    t.bigint "registrable_id", null: false
    t.index ["registrable_type", "registrable_id"], name: "index_app_configs_on_registrable_type_and_registrable_id"
  end

  create_table "app_notifications", force: :cascade do |t|
    t.string "message", default: ""
    t.boolean "read", default: false
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title"
    t.string "bn_title", default: ""
    t.string "bn_message", default: ""
    t.index ["notifiable_type", "notifiable_id"], name: "index_app_notifications_on_notifiable_type_and_notifiable_id"
  end

  create_table "areas", force: :cascade do |t|
    t.integer "thana_id", null: false
    t.string "name", null: false
    t.string "bn_name", null: false
    t.boolean "is_deleted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "home_delivery", default: false
  end

  create_table "articles", force: :cascade do |t|
    t.bigint "help_topic_id", null: false
    t.string "title"
    t.text "body"
    t.boolean "public_visibility", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "bn_title", default: ""
    t.text "bn_body", default: ""
    t.string "slug"
    t.boolean "footer_visibility", default: false
    t.integer "position", default: 0
    t.boolean "is_deletable", default: true
    t.integer "created_by_id"
    t.index ["help_topic_id"], name: "index_articles_on_help_topic_id"
    t.index ["slug"], name: "index_articles_on_slug", unique: true
  end

  create_table "asset_locations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "attribute_set_product_attributes", force: :cascade do |t|
    t.bigint "attribute_set_id", null: false
    t.bigint "product_attribute_id", null: false
    t.integer "created_by_id"
    t.index ["attribute_set_id"], name: "index_attribute_set_product_attributes_on_attribute_set_id"
    t.index ["product_attribute_id"], name: "index_attribute_set_product_attributes_on_product_attribute_id"
  end

  create_table "attribute_sets", force: :cascade do |t|
    t.string "title"
    t.integer "created_by_id"
    t.string "unique_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "authorization_keys", force: :cascade do |t|
    t.text "token"
    t.string "otp"
    t.datetime "expiry"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "old_token"
    t.integer "authable_id"
    t.string "authable_type"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.string "title", null: false
    t.string "bank_name", null: false
    t.string "account_name", null: false
    t.string "account_number", null: false
    t.string "branch_name", null: false
    t.string "ownerable_type"
    t.integer "ownerable_id"
    t.string "note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_by_id"
  end

  create_table "bank_transactions", force: :cascade do |t|
    t.decimal "amount", null: false
    t.string "transactionable_for_type"
    t.integer "transactionable_for_id"
    t.string "transactionable_by_type"
    t.integer "transactionable_by_id"
    t.string "transactionable_to_type"
    t.integer "transactionable_to_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "chalan_no", default: ""
    t.boolean "is_approved", default: false
    t.bigint "debit_bank_account_id"
    t.bigint "credit_bank_account_id"
    t.datetime "finance_received_at"
    t.integer "created_by_id"
    t.index ["credit_bank_account_id"], name: "index_bank_transactions_on_credit_bank_account_id"
    t.index ["debit_bank_account_id"], name: "index_bank_transactions_on_debit_bank_account_id"
  end

  create_table "banner_images", force: :cascade do |t|
    t.integer "promo_banner_id"
    t.integer "image_type", default: 0
    t.string "redirect_url", default: ""
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "image_title", default: ""
    t.string "description", default: ""
  end

  create_table "blocked_items", force: :cascade do |t|
    t.integer "warehouse_id"
    t.integer "variant_id"
    t.integer "blocked_quantity", default: 0
    t.integer "garbage_quantity", default: 0
    t.integer "unblocked_quantity", default: 0
    t.integer "blocked_reason"
    t.text "note"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_by_id"
  end

  create_table "box_line_items", force: :cascade do |t|
    t.bigint "line_item_id", null: false
    t.bigint "box_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["box_id"], name: "index_box_line_items_on_box_id"
    t.index ["line_item_id"], name: "index_box_line_items_on_line_item_id"
  end

  create_table "boxes", force: :cascade do |t|
    t.bigint "dh_purchase_order_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", default: 0
    t.string "boxable_type"
    t.bigint "boxable_id"
    t.integer "created_by_id"
    t.index ["boxable_type", "boxable_id"], name: "index_boxes_on_boxable_type_and_boxable_id"
    t.index ["dh_purchase_order_id"], name: "index_boxes_on_dh_purchase_order_id"
  end

  create_table "brand_followings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "brand_id", null: false
    t.index ["brand_id"], name: "index_brand_followings_on_brand_id"
    t.index ["user_id"], name: "index_brand_followings_on_user_id"
  end

  create_table "brand_promotions", force: :cascade do |t|
    t.integer "promotion_id"
    t.integer "brand_id"
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "brands", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_own_brand", default: false
    t.string "slug"
    t.string "bn_name", default: ""
    t.boolean "is_deleted", default: false
    t.boolean "public_visibility", default: true
    t.integer "branding_layout", default: 0
    t.integer "branding_promotion_with", default: 0
    t.string "branding_video_url"
    t.string "branding_title"
    t.string "branding_title_bn"
    t.string "branding_subtitle"
    t.string "branding_subtitle_bn"
    t.string "short_description"
    t.string "short_description_bn"
    t.string "more_info_button_text"
    t.string "more_info_button_text_bn"
    t.string "more_info_url"
    t.boolean "brand_info_visible", default: true
    t.boolean "homepage_visibility", default: false
    t.string "redirect_url"
    t.integer "created_by_id"
    t.string "unique_id"
    t.index ["slug"], name: "index_brands_on_slug", unique: true
  end

  create_table "bulk_upload_tmp_images", force: :cascade do |t|
    t.string "file_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["file_name"], name: "index_bulk_upload_tmp_images_on_file_name", unique: true
  end

  create_table "bundle_variants", force: :cascade do |t|
    t.integer "bundle_id", null: false
    t.integer "variant_id", null: false
    t.integer "quantity", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bundles", force: :cascade do |t|
    t.integer "variant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_editable", default: true
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "title"
    t.string "title_bn"
    t.string "page_url"
    t.string "campaignable_type", null: false
    t.bigint "campaignable_id", null: false
    t.integer "created_by_id"
    t.index ["campaignable_type", "campaignable_id"], name: "index_campaigns_on_campaignable_type_and_campaignable_id"
  end

  create_table "cart_promotions", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "promotion_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cart_id"], name: "index_cart_promotions_on_cart_id"
    t.index ["promotion_id"], name: "index_cart_promotions_on_promotion_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
    t.decimal "sub_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "cart_discount", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_discount", precision: 10, scale: 2, default: "0.0"
    t.integer "partner_id"
    t.integer "promotion_id"
    t.string "coupon_code"
    t.string "cart_dis_type"
    t.integer "business_type", default: 0
  end

  create_table "categories", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "parent_id"
    t.string "bn_title", null: false
    t.text "bn_description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "home_page_visibility", default: true
    t.integer "position"
    t.string "slug"
    t.integer "created_by_id"
    t.integer "business_type", default: 0
    t.string "unique_id"
    t.index ["position"], name: "index_categories_on_position"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "challan_line_items", force: :cascade do |t|
    t.bigint "challan_id", null: false
    t.bigint "customer_order_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "received_at"
    t.bigint "received_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "challans", force: :cascade do |t|
    t.bigint "distributor_id", null: false
    t.integer "status", default: 0, null: false
    t.bigint "created_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "warehouse_id"
    t.integer "sno_challan_id"
    t.boolean "is_deleted", default: false
  end

  create_table "company_assets", force: :cascade do |t|
    t.bigint "oc_line_item_id", null: false
    t.bigint "asset_location_id"
    t.bigint "oc_product_id"
    t.string "tag"
    t.string "details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["asset_location_id"], name: "index_company_assets_on_asset_location_id"
    t.index ["oc_line_item_id"], name: "index_company_assets_on_oc_line_item_id"
    t.index ["oc_product_id"], name: "index_company_assets_on_oc_product_id"
    t.index ["tag"], name: "index_company_assets_on_tag", unique: true
  end

  create_table "configurations", force: :cascade do |t|
    t.string "key", null: false
    t.float "value", default: 0.0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "version_config"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "corporate_users", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "phone", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "warehouse_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_corporate_users_on_email", unique: true
  end

  create_table "coupon_categories", force: :cascade do |t|
    t.bigint "coupon_id", null: false
    t.integer "category_inclusion_type", default: 0
    t.text "category_ids", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "coupon_users", force: :cascade do |t|
    t.float "discount_amount", default: 0.0
    t.boolean "is_used", default: false
    t.integer "user_id", null: false
    t.integer "coupon_id", null: false
    t.integer "customer_order_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "code"
    t.boolean "is_expired", default: false
  end

  create_table "coupons", force: :cascade do |t|
    t.string "code", null: false
    t.decimal "discount_amount", precision: 10, scale: 2
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_used", default: false
    t.boolean "is_deleted", default: false
    t.integer "usable_id"
    t.string "usable_type"
    t.integer "promotion_id"
    t.integer "customer_order_id"
    t.integer "return_customer_order_id"
    t.decimal "cart_value"
    t.integer "aggregate_return_id"
    t.bigint "promo_coupon_id"
    t.integer "used_count", default: 0
    t.integer "coupon_type", default: 0
    t.boolean "is_active", default: true
    t.integer "discount_type", default: 0
    t.decimal "max_limit", precision: 10, scale: 2, default: "0.0"
    t.integer "max_user_limit"
    t.integer "number_of_uses", default: 1
    t.text "skus"
    t.text "phone_numbers"
    t.integer "created_by_id"
    t.boolean "is_visible", default: true
    t.integer "sku_inclusion_type", default: 0
  end

  create_table "customer_acquisitions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "registered_by_id"
    t.string "registered_by_type"
    t.float "amount"
    t.bigint "coupon_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_paid", default: false
    t.integer "information_status", default: 0, null: false
  end

  create_table "customer_care_agents", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "phone", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "warehouse_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_active", default: true
    t.integer "status", default: 0
    t.index ["email"], name: "index_customer_care_agents_on_email", unique: true
  end

  create_table "customer_care_reports", force: :cascade do |t|
    t.integer "report_type", default: 0
    t.bigint "customer_order_id", null: false
    t.string "reporter_type"
    t.bigint "reporter_id"
    t.index ["customer_order_id"], name: "index_customer_care_reports_on_customer_order_id"
    t.index ["reporter_type", "reporter_id"], name: "index_customer_care_reports_on_reporter_type_and_reporter_id"
  end

  create_table "customer_device_users", force: :cascade do |t|
    t.bigint "customer_device_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "customer_devices", force: :cascade do |t|
    t.string "device_id"
    t.string "device_model"
    t.string "device_os_type"
    t.string "device_os_version"
    t.string "email"
    t.string "phone"
    t.string "app_version"
    t.string "app_language"
    t.string "fcm_id"
    t.string "ip"
    t.string "brand"
    t.string "imei"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "customer_order_promotions", force: :cascade do |t|
    t.bigint "customer_order_id", null: false
    t.bigint "promotion_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_order_id"], name: "index_customer_order_promotions_on_customer_order_id"
    t.index ["promotion_id"], name: "index_customer_order_promotions_on_promotion_id"
  end

  create_table "customer_order_status_changes", force: :cascade do |t|
    t.bigint "customer_order_id", null: false
    t.bigint "order_status_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "changed_by_id"
    t.string "changed_by_type"
    t.index ["customer_order_id"], name: "index_customer_order_status_changes_on_customer_order_id"
    t.index ["order_status_id"], name: "index_customer_order_status_changes_on_order_status_id"
  end

  create_table "customer_orders", force: :cascade do |t|
    t.string "number"
    t.integer "item_count"
    t.text "special_instruction"
    t.integer "pay_type"
    t.decimal "cart_total_price", precision: 10, scale: 2, default: "0.0"
    t.integer "for_whom"
    t.datetime "completed_at"
    t.string "coupon_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "customer_type"
    t.bigint "customer_id"
    t.decimal "total_discount_amount", default: "0.0"
    t.decimal "total_price", default: "0.0"
    t.bigint "billing_address_id"
    t.bigint "shipping_address_id"
    t.bigint "partner_id"
    t.integer "shipping_type", default: 0
    t.bigint "warehouse_id"
    t.decimal "shipping_charge", precision: 10, scale: 2, default: "0.0"
    t.integer "order_type", default: 0, null: false
    t.integer "order_status_id"
    t.integer "pay_status", default: 0
    t.string "name"
    t.string "phone"
    t.bigint "rider_id"
    t.string "pin"
    t.text "cancellation_reason"
    t.decimal "partner_commission", default: "0.0"
    t.date "preferred_delivery_date"
    t.boolean "is_customer_paid", default: false
    t.integer "next_shipping_type"
    t.integer "next_partner_id"
    t.decimal "holding_fee", precision: 10, scale: 2, default: "0.0"
    t.integer "promotion_id"
    t.integer "customer_orderable_id"
    t.string "customer_orderable_type"
    t.boolean "return_coupon", default: false
    t.decimal "vat_shipping_charge", precision: 8, scale: 2, default: "0.0"
    t.bigint "distributor_id"
    t.string "platform"
    t.bigint "customer_device_id"
    t.integer "tenure"
    t.integer "created_by_id"
    t.integer "business_type", default: 0
    t.index ["billing_address_id"], name: "index_customer_orders_on_billing_address_id"
    t.index ["customer_type", "customer_id"], name: "index_customer_orders_on_customer_type_and_customer_id"
    t.index ["rider_id"], name: "index_customer_orders_on_rider_id"
    t.index ["shipping_address_id"], name: "index_customer_orders_on_shipping_address_id"
    t.index ["warehouse_id"], name: "index_customer_orders_on_warehouse_id"
  end

  create_table "delivery_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "partner_id"
    t.integer "pay_type"
    t.integer "shipping_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "default", default: false, null: false
    t.index ["user_id"], name: "index_delivery_preferences_on_user_id"
  end

  create_table "dh_purchase_orders", force: :cascade do |t|
    t.integer "warehouse_id", null: false
    t.integer "order_by"
    t.decimal "quantity", precision: 8, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.datetime "order_date"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order_status", default: 0
    t.integer "created_by_id"
  end

  create_table "distributor_margins", force: :cascade do |t|
    t.integer "customer_order_id", null: false
    t.integer "distributor_id", null: false
    t.integer "payable_id"
    t.string "payable_type"
    t.datetime "paid_at"
    t.boolean "is_commissionable", default: true
    t.decimal "amount", default: "0.0"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_by_id"
  end

  create_table "distributors", force: :cascade do |t|
    t.string "name"
    t.string "bn_name"
    t.integer "warehouse_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: ""
    t.string "phone", default: ""
    t.string "address", default: ""
    t.string "code", default: ""
    t.integer "status", default: 0
    t.boolean "is_commission_applicable", default: true
    t.boolean "home_delivery", default: false
    t.integer "created_by_id"
  end

  create_table "districts", force: :cascade do |t|
    t.string "name", null: false
    t.string "bn_name", null: false
    t.boolean "is_deleted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "warehouse_id"
    t.integer "created_by_id"
    t.index ["warehouse_id"], name: "index_districts_on_warehouse_id"
  end

  create_table "failed_qcs", force: :cascade do |t|
    t.integer "variant_id"
    t.integer "quantity"
    t.string "failable_type"
    t.bigint "failable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "failed_reasons", default: {}
    t.integer "warehouse_id"
    t.integer "qc_failed_type", default: 0
    t.boolean "is_settled", default: false
    t.integer "customer_order_id"
    t.integer "received_quantity", default: 0
    t.integer "closed_quantity", default: 0
    t.integer "line_item_id"
    t.datetime "closed_at"
    t.integer "created_by_id"
    t.index ["failable_type", "failable_id"], name: "index_failed_qcs_on_failable_type_and_failable_id"
  end

  create_table "favorite_stores", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "partner_id", null: false
    t.index ["partner_id"], name: "index_favorite_stores_on_partner_id"
    t.index ["user_id"], name: "index_favorite_stores_on_user_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "message"
    t.integer "rating", default: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "filtering_options", force: :cascade do |t|
    t.integer "filtering_type", default: 0
    t.string "filtering_keys", default: [], array: true
    t.string "filterable_type", null: false
    t.bigint "filterable_id", null: false
    t.index ["filterable_type", "filterable_id"], name: "index_filtering_options_on_filterable_type_and_filterable_id"
  end

  create_table "frequently_asked_questions", force: :cascade do |t|
    t.text "question", null: false
    t.text "bn_question", null: false
    t.text "answer"
    t.text "bn_answer"
    t.integer "product_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bn_question"], name: "index_frequently_asked_questions_on_bn_question"
    t.index ["product_id"], name: "index_frequently_asked_questions_on_product_id"
    t.index ["question"], name: "index_frequently_asked_questions_on_question"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "help_topics", force: :cascade do |t|
    t.string "title"
    t.boolean "public_visibility", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "bn_title", default: ""
    t.string "slug"
    t.boolean "is_deletable", default: true
    t.integer "created_by_id"
    t.index ["slug"], name: "index_help_topics_on_slug", unique: true
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "customer_order_id", null: false
    t.index ["customer_order_id"], name: "index_invoices_on_customer_order_id"
  end

  create_table "jwt_blacklist", force: :cascade do |t|
    t.string "jti", null: false
    t.index ["jti"], name: "index_jwt_blacklist_on_jti"
  end

  create_table "line_item_locations", force: :cascade do |t|
    t.integer "location_id"
    t.integer "shopoth_line_item_id"
    t.integer "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "qr_codes", default: [], array: true
  end

  create_table "line_items", force: :cascade do |t|
    t.integer "variant_id", null: false
    t.integer "quantity", null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0"
    t.string "itemable_type"
    t.bigint "itemable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "received_quantity", default: 0
    t.integer "qc_passed", default: 0
    t.integer "qc_failed", default: 0
    t.boolean "qc_status", default: false
    t.integer "location_id"
    t.integer "remaining_quantity", default: 0
    t.integer "reconcilation_status", default: 0
    t.string "qr_code", default: ""
    t.integer "send_quantity", default: 0
    t.integer "settled_quantity", default: 0
    t.index ["itemable_type", "itemable_id"], name: "index_line_items_on_itemable_type_and_itemable_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "code"
    t.integer "warehouse_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_by_id"
  end

  create_table "meta_data", force: :cascade do |t|
    t.string "meta_title"
    t.string "bn_meta_title"
    t.text "meta_description"
    t.text "bn_meta_description"
    t.text "meta_keyword", default: [], array: true
    t.text "bn_meta_keyword", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "metable_type"
    t.bigint "metable_id"
    t.integer "created_by_id"
    t.index ["metable_type", "metable_id"], name: "index_meta_data_on_metable_type_and_metable_id"
  end

  create_table "month_wise_payment_histories", force: :cascade do |t|
    t.integer "warehouse_id"
    t.float "fc_total_collection"
    t.float "fc_commission"
    t.float "partner_commission"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "payable_amount", default: 0.0
    t.float "return_amount", default: 0.0
    t.string "month"
    t.integer "distributor_id"
    t.decimal "agent_commission", default: "0.0"
    t.decimal "total_collection", default: "0.0"
  end

  create_table "news_letters", force: :cascade do |t|
    t.string "email", null: false
    t.boolean "is_active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "token"
  end

  create_table "notifications", force: :cascade do |t|
    t.text "details"
    t.boolean "read", default: false, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_notifiable_id"
    t.string "user_notifiable_type"
    t.text "bn_details"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "oc_categories", force: :cascade do |t|
    t.string "title"
    t.integer "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "oc_line_items", force: :cascade do |t|
    t.bigint "oc_product_id", null: false
    t.bigint "oc_purchase_order_id", null: false
    t.integer "quantity"
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_price", precision: 10, scale: 2, default: "0.0"
    t.datetime "acquisition_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["oc_product_id"], name: "index_oc_line_items_on_oc_product_id"
    t.index ["oc_purchase_order_id"], name: "index_oc_line_items_on_oc_purchase_order_id"
  end

  create_table "oc_products", force: :cascade do |t|
    t.string "title"
    t.integer "root_category_id", null: false
    t.string "leaf_category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "model_title"
  end

  create_table "oc_purchase_orders", force: :cascade do |t|
    t.bigint "oc_supplier_id", null: false
    t.integer "quantity"
    t.decimal "total_price", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["oc_supplier_id"], name: "index_oc_purchase_orders_on_oc_supplier_id"
  end

  create_table "oc_suppliers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "order_statuses", force: :cascade do |t|
    t.integer "order_type", default: 0
    t.string "system_order_status", default: ""
    t.string "customer_order_status", default: ""
    t.string "admin_order_status", default: ""
    t.string "sales_representative_order_status", default: ""
    t.string "partner_order_status", default: ""
    t.string "bn_customer_order_status", default: ""
  end

  create_table "partner_margins", force: :cascade do |t|
    t.integer "customer_order_id", null: false
    t.integer "partner_id", null: false
    t.string "order_type", null: false
    t.decimal "margin_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "route_received_at"
    t.datetime "partner_received_at"
    t.decimal "route_received_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "partner_received_amount", precision: 10, scale: 2, default: "0.0"
    t.integer "created_by_id"
  end

  create_table "partner_shops", force: :cascade do |t|
    t.integer "sales_representative_id", null: false
    t.string "day", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "partners", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone"
    t.string "email"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "schedule", default: 0
    t.string "tsa_id"
    t.integer "route_id"
    t.string "retailer_code"
    t.string "partner_code"
    t.string "region"
    t.string "area"
    t.string "territory"
    t.string "owner_name"
    t.string "cluster_name"
    t.string "sub_channel"
    t.decimal "latitude", precision: 15, scale: 12, default: "0.0"
    t.decimal "longitude", precision: 15, scale: 12, default: "0.0"
    t.string "bn_name"
    t.string "encrypted_password", default: "", null: false
    t.text "point"
    t.string "scope", default: "expansion"
    t.boolean "is_commission_applicable", default: true
    t.text "work_days", default: "---\n- :is_opened: false\n- :is_opened: false\n- :is_opened: false\n- :is_opened: false\n- :is_opened: false\n- :is_opened: false\n- :is_opened: false\n"
    t.string "slug"
    t.boolean "is_b2b", default: false
    t.string "bkash_number"
    t.integer "created_by_id"
    t.integer "business_type", default: 0
    t.index ["slug"], name: "index_partners_on_slug", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "currency_amount", precision: 10, scale: 2, null: false
    t.string "currency_type", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "form_of_payment", default: 0, null: false
    t.string "paymentable_type"
    t.bigint "paymentable_id"
    t.bigint "customer_order_id"
    t.string "bkash_payment_id"
    t.string "bkash_transaction_status"
    t.integer "receiver_id"
    t.string "receiver_type"
    t.string "nagad_payment_reference_id"
    t.integer "category"
    t.integer "aggregated_payment_id"
    t.string "payment_reference_id", default: ""
    t.index ["customer_order_id"], name: "index_payments_on_customer_order_id"
    t.index ["paymentable_type", "paymentable_id", "receiver_type", "receiver_id", "customer_order_id"], name: "uniq_payment", unique: true
    t.index ["paymentable_type", "paymentable_id"], name: "index_payments_on_paymentable_type_and_paymentable_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.boolean "all", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "staff_id"
    t.string "resource_name"
    t.boolean "list_permission?", default: false
    t.boolean "create_permission?", default: false
    t.boolean "edit_permission?", default: false
    t.boolean "delete_permission?", default: false
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "product_attribute_images", force: :cascade do |t|
    t.integer "product_id"
    t.integer "product_attribute_value_id"
    t.boolean "is_default", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_deleted", default: false
  end

  create_table "product_attribute_values", force: :cascade do |t|
    t.integer "product_attribute_id"
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "bn_value"
    t.boolean "is_deleted", default: false
    t.string "unique_id"
  end

  create_table "product_attribute_values_variants", force: :cascade do |t|
    t.integer "variant_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "product_attribute_value_id"
    t.boolean "is_deleted", default: false
  end

  create_table "product_attributes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "bn_name"
    t.boolean "is_deleted", default: false
    t.integer "created_by_id"
    t.string "unique_id"
  end

  create_table "product_categories", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "category_id", null: false
    t.integer "sub_category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_by_id"
    t.index ["category_id"], name: "index_product_categories_on_category_id"
    t.index ["product_id"], name: "index_product_categories_on_product_id"
    t.index ["sub_category_id"], name: "index_product_categories_on_sub_category_id"
  end

  create_table "product_features", force: :cascade do |t|
    t.integer "product_id"
    t.string "title", default: ""
    t.string "bn_title", default: ""
    t.string "description", default: ""
    t.string "bn_description", default: ""
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_by_id"
  end

  create_table "product_types", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "bn_title"
    t.string "slug"
    t.integer "created_by_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "bn_title"
    t.string "bn_description"
    t.boolean "is_deleted", default: false
    t.text "short_description"
    t.text "bn_short_description"
    t.string "warranty_period"
    t.text "warranty_policy"
    t.text "bn_warranty_policy"
    t.text "inside_box"
    t.text "bn_inside_box"
    t.string "video_url"
    t.integer "warranty_type"
    t.string "dangerous_goods"
    t.integer "sku_type"
    t.integer "warranty_period_type"
    t.string "company", default: "", null: false
    t.string "bn_company", default: ""
    t.string "certification"
    t.string "bn_certification"
    t.string "license_required"
    t.string "material"
    t.string "bn_material"
    t.text "bn_broad_description"
    t.text "consumption_guidelines"
    t.text "bn_consumption_guidelines"
    t.string "temperature_requirement", default: ""
    t.string "bn_temperature_requirement", default: ""
    t.string "keywords"
    t.text "brand_message"
    t.text "tagline"
    t.string "product_type"
    t.text "product_specifications"
    t.string "status", default: "new"
    t.integer "leaf_category_id"
    t.integer "root_category_id"
    t.string "slug"
    t.boolean "is_refundable", default: true
    t.text "return_policy", default: ""
    t.integer "sell_count", default: 0
    t.text "bn_return_policy", default: ""
    t.integer "brand_id"
    t.bigint "attribute_set_id"
    t.integer "image_attribute_id"
    t.boolean "public_visibility", default: true
    t.integer "max_quantity_per_order"
    t.integer "weight", default: 0, null: false
    t.boolean "is_emi_available", default: false
    t.integer "tenures", default: [], array: true
    t.integer "created_by_id"
    t.integer "business_type", default: 0
    t.string "unique_id"
    t.index ["attribute_set_id"], name: "index_products_on_attribute_set_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["title"], name: "index_products_on_title"
  end

  create_table "products_product_types", force: :cascade do |t|
    t.integer "product_id"
    t.integer "product_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_by_id"
  end

  create_table "promo_banners", force: :cascade do |t|
    t.string "title"
    t.integer "layout"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_visible", default: false
    t.integer "created_by_id"
  end

  create_table "promo_coupon_rules", force: :cascade do |t|
    t.bigint "promo_coupon_id", null: false
    t.string "ruleable_type"
    t.bigint "ruleable_id"
    t.index ["ruleable_type", "ruleable_id"], name: "index_promo_coupon_rules_on_ruleable_type_and_ruleable_id"
  end

  create_table "promo_coupons", force: :cascade do |t|
    t.integer "status", default: 1, null: false
    t.datetime "start_date"
    t.integer "order_type", default: 0
    t.datetime "end_date"
    t.float "minimum_cart_value"
    t.float "discount"
    t.float "max_discount_amount"
    t.integer "discount_type", default: 0
    t.boolean "is_deleted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "usable_count", default: 1
    t.integer "usable_count_per_person", default: 1
    t.integer "number_of_coupon"
    t.string "title"
    t.integer "created_by_id"
  end

  create_table "promotion_rules", force: :cascade do |t|
    t.integer "promotion_id", null: false
    t.string "name"
    t.decimal "value", precision: 10, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "promotion_variants", force: :cascade do |t|
    t.integer "promotion_id", null: false
    t.integer "variant_id", null: false
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "promotional_price", precision: 10, scale: 2, default: "0.0"
    t.decimal "promotional_discount", precision: 10, scale: 2, default: "0.0"
    t.bigint "product_id"
    t.integer "created_by_id"
    t.index ["product_id"], name: "index_promotion_variants_on_product_id"
  end

  create_table "promotions", force: :cascade do |t|
    t.integer "warehouse_id"
    t.integer "promotion_category", default: 0
    t.date "from_date"
    t.date "to_date"
    t.boolean "is_active", default: true
    t.boolean "is_time_bound", default: false
    t.string "start_time"
    t.string "end_time"
    t.string "days", array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title"
    t.string "rule"
    t.string "title_bn", default: ""
    t.integer "created_by_id"
    t.index ["promotion_category"], name: "index_promotions_on_promotion_category"
    t.index ["warehouse_id"], name: "index_promotions_on_warehouse_id"
  end

  create_table "purchase_order_invoices", force: :cascade do |t|
    t.integer "purchase_order_id"
    t.string "purchase_order_type"
    t.text "order_to"
    t.text "order_from"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "purchase_order_statuses", force: :cascade do |t|
    t.string "orderable_type"
    t.integer "orderable_id"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "changed_by_id"
    t.string "changed_by_type"
    t.integer "created_by_id"
  end

  create_table "questionnaires", force: :cascade do |t|
    t.text "question", null: false
    t.integer "category_id"
    t.integer "questionnaire_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ra_coupons", force: :cascade do |t|
    t.integer "promotion_id"
    t.integer "retailer_assistant_id"
    t.string "code"
    t.boolean "is_used", default: false
    t.boolean "is_deleted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "requested_variants", force: :cascade do |t|
    t.integer "variant_id", null: false
    t.integer "user_id", null: false
    t.integer "warehouse_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_deleted", default: false
  end

  create_table "retailer_assistants", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "email"
    t.integer "status", default: 1
    t.string "bn_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "father_name"
    t.string "experience"
    t.string "education"
    t.string "nid"
    t.string "tech_skill"
    t.datetime "date_of_birth"
    t.integer "warehouse_id"
    t.integer "category", default: 0
    t.string "otp"
    t.integer "distributor_id"
    t.integer "created_by_id"
    t.index ["warehouse_id"], name: "index_retailer_assistants_on_warehouse_id"
  end

  create_table "return_challan_line_items", force: :cascade do |t|
    t.bigint "return_challan_id", null: false
    t.bigint "orderable_id", null: false
    t.string "orderable_type", null: false
    t.integer "status", default: 0, null: false
    t.datetime "received_at"
    t.bigint "received_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "return_challans", force: :cascade do |t|
    t.bigint "warehouse_id", null: false
    t.bigint "distributor_id", null: false
    t.integer "status", default: 0, null: false
    t.bigint "created_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "sno_return_challan_id"
    t.boolean "is_deleted", default: false
  end

  create_table "return_customer_orders", force: :cascade do |t|
    t.integer "return_status", default: 0
    t.bigint "customer_order_id", null: false
    t.bigint "partner_id"
    t.integer "return_type", default: 0
    t.datetime "delivered_to_sr_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "rider_id"
    t.integer "reason", default: 0
    t.string "description"
    t.string "qr_code"
    t.bigint "shopoth_line_item_id"
    t.date "preferred_delivery_date"
    t.text "cancellation_reason"
    t.integer "form_of_return", default: 0
    t.bigint "warehouse_id"
    t.integer "return_orderable_id"
    t.string "return_orderable_type"
    t.integer "qc_status"
    t.decimal "sub_total", precision: 10, scale: 2, default: "0.0"
    t.boolean "refunded", default: false
    t.integer "aggregate_return_id"
    t.bigint "distributor_id"
    t.integer "created_by_id"
    t.integer "quantity"
    t.index ["customer_order_id"], name: "index_return_customer_orders_on_customer_order_id"
    t.index ["partner_id"], name: "index_return_customer_orders_on_partner_id"
    t.index ["rider_id"], name: "index_return_customer_orders_on_rider_id"
    t.index ["shopoth_line_item_id"], name: "index_return_customer_orders_on_shopoth_line_item_id"
    t.index ["warehouse_id"], name: "index_return_customer_orders_on_warehouse_id"
  end

  create_table "return_status_changes", force: :cascade do |t|
    t.bigint "return_customer_order_id", null: false
    t.string "status"
    t.string "changeable_type"
    t.integer "changeable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_by_id"
    t.index ["return_customer_order_id"], name: "index_return_status_changes_on_return_customer_order_id"
  end

  create_table "return_transfer_orders", force: :cascade do |t|
    t.integer "warehouse_id", null: false
    t.integer "order_by"
    t.integer "quantity", default: 0
    t.decimal "total_price", precision: 10, scale: 2
    t.integer "order_status", default: 0
    t.boolean "is_deleted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_by_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.string "title", null: false
    t.integer "rating", default: 0
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "description"
    t.integer "shopoth_line_item_id"
    t.boolean "is_approved", default: false
    t.string "reviewable_type"
    t.bigint "reviewable_id"
    t.boolean "is_recommended", default: false
    t.bigint "customer_order_id"
    t.index ["customer_order_id"], name: "index_reviews_on_customer_order_id"
    t.index ["reviewable_type", "reviewable_id"], name: "index_reviews_on_reviewable_type_and_reviewable_id"
  end

  create_table "riders", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "phone", default: "", null: false
    t.string "email", default: ""
    t.string "password_hash", default: "", null: false
    t.bigint "warehouse_id", null: false
    t.decimal "cash_collected", default: "0.0"
    t.integer "distributor_id"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "created_by_id"
    t.index ["warehouse_id"], name: "index_riders_on_warehouse_id"
  end

  create_table "route_devices", force: :cascade do |t|
    t.string "device_id", null: false
    t.string "password_hash"
    t.integer "route_id"
    t.string "unique_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_by_id"
    t.index ["device_id"], name: "index_route_devices_on_device_id"
  end

  create_table "routes", force: :cascade do |t|
    t.string "title", null: false
    t.string "bn_title", null: false
    t.string "phone"
    t.integer "warehouse_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "cash_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "digital_amount", precision: 10, scale: 2, default: "0.0"
    t.string "sr_point"
    t.string "sr_name"
    t.integer "distributor_id"
    t.string "bkash_number"
    t.integer "created_by_id"
    t.index ["title"], name: "index_routes_on_title"
  end

  create_table "sales_representatives", force: :cascade do |t|
    t.integer "warehouse_id", null: false
    t.string "name", null: false
    t.string "bn_name"
    t.string "area", null: false
    t.string "bn_area"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "searches", force: :cascade do |t|
    t.integer "warehouse_id"
    t.integer "user_id"
    t.string "search_key", null: false
    t.string "product_ids", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "shopoth_line_items", force: :cascade do |t|
    t.integer "cart_id"
    t.integer "customer_order_id"
    t.integer "quantity", default: 1
    t.decimal "price", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "variant_id"
    t.string "qr_codes", default: [], array: true
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "sub_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "retailer_price", precision: 10, scale: 2, default: "0.0"
    t.integer "promotion_id"
    t.integer "location_id"
    t.integer "sample_for"
    t.integer "product_quantity_limit"
    t.integer "sno_order_item_id"
    t.index ["variant_id"], name: "index_shopoth_line_items_on_variant_id"
  end

  create_table "slider_configs", force: :cascade do |t|
    t.integer "interval"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "slides", force: :cascade do |t|
    t.string "name"
    t.text "body"
    t.string "link_url"
    t.boolean "published", default: true
    t.integer "position", default: 0, null: false
    t.integer "product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "image"
    t.integer "img_type", default: 0
    t.integer "created_by_id"
  end

  create_table "sms_logs", force: :cascade do |t|
    t.integer "sms_type"
    t.string "content"
    t.json "gateway_response"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["phone"], name: "index_sms_logs_on_phone"
  end

  create_table "social_links", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_by_id"
  end

  create_table "staff_roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "staffs", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", default: "", null: false
    t.integer "staff_role_id"
    t.integer "warehouse_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "address_line"
    t.string "encrypted_password"
    t.integer "unit", default: 0
    t.boolean "is_active", default: true
    t.integer "staffable_id"
    t.string "staffable_type"
    t.index ["email"], name: "index_staffs_on_email", unique: true
  end

  create_table "static_pages", force: :cascade do |t|
    t.integer "page_type"
  end

  create_table "stock_changes", force: :cascade do |t|
    t.integer "available_quantity", default: 0
    t.integer "booked_quantity", default: 0
    t.integer "packed_quantity", default: 0
    t.integer "in_transit_quantity", default: 0
    t.integer "in_partner_quantity", default: 0
    t.integer "blocked_quantity", default: 0
    t.integer "warehouse_variant_id", null: false
    t.integer "stock_changeable_id", null: false
    t.string "stock_changeable_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "quantity", default: 0
    t.integer "garbage_quantity", default: 0
    t.integer "available_quantity_change", default: 0
    t.integer "booked_quantity_change", default: 0
    t.integer "packed_quantity_change", default: 0
    t.integer "in_transit_quantity_change", default: 0
    t.integer "in_partner_quantity_change", default: 0
    t.integer "blocked_quantity_change", default: 0
    t.integer "garbage_quantity_change", default: 0
    t.integer "warehouse_id"
    t.integer "stock_transaction_type"
    t.integer "variant_id"
    t.integer "qc_pending_quantity", default: 0
    t.integer "qc_pending_quantity_change", default: 0
    t.integer "qty_qc_failed_quantity", default: 0
    t.integer "qty_qc_failed_quantity_change", default: 0
    t.integer "qly_qc_failed_quantity", default: 0
    t.integer "qly_qc_failed_quantity_change", default: 0
    t.integer "location_pending_quantity", default: 0
    t.integer "location_pending_quantity_change", default: 0
    t.integer "return_in_partner_quantity", default: 0
    t.integer "return_in_partner_quantity_change", default: 0
    t.integer "return_in_transit_quantity", default: 0
    t.integer "return_in_transit_quantity_change", default: 0
    t.integer "return_qc_pending_quantity", default: 0
    t.integer "return_qc_pending_quantity_change", default: 0
    t.integer "return_location_pending_quantity", default: 0
    t.integer "return_location_pending_quantity_change", default: 0
    t.integer "ready_to_ship_from_fc_quantity", default: 0
    t.integer "ready_to_ship_from_fc_quantity_change", default: 0
    t.integer "in_transit_to_dh_quantity", default: 0
    t.integer "in_transit_to_dh_quantity_change", default: 0
    t.integer "ready_to_ship_quantity", default: 0
    t.integer "ready_to_ship_quantity_change", default: 0
    t.integer "return_in_dh_quantity", default: 0
    t.integer "return_in_dh_quantity_change", default: 0
    t.integer "return_in_transit_to_fc_quantity", default: 0
    t.integer "return_in_transit_to_fc_quantity_change", default: 0
    t.integer "return_qc_failed_quantity", default: 0
    t.integer "return_qc_failed_quantity_change", default: 0
    t.index ["stock_changeable_id", "stock_changeable_type", "stock_transaction_type", "warehouse_variant_id"], name: "uniq_stock_change", unique: true, where: "(stock_transaction_type <> ALL (ARRAY[5, 10, 15, 17, 18, 19, 20]))"
  end

  create_table "storage_variants", force: :cascade do |t|
    t.integer "warehouse_storage_id", null: false
    t.integer "variant_id", null: false
    t.integer "quantity", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "store_infos", force: :cascade do |t|
    t.string "official_email", null: false
    t.text "contact_address", null: false
    t.integer "contact_number", null: false
    t.string "footer_bottom"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "phone"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "delivery_type"
    t.boolean "is_deleted", default: false
    t.string "mou_document_number"
    t.string "supplier_name"
    t.string "supplier_representative"
    t.string "representative_designation"
    t.string "representative_contact"
    t.string "tin"
    t.string "bin"
    t.date "contract_start_date"
    t.date "contract_end_date"
    t.string "bank_name"
    t.string "account_number"
    t.string "swift_code"
    t.string "central_warehouse_address"
    t.string "local_warehouse_address"
    t.boolean "pre_payment"
    t.decimal "product_quality_rating", precision: 10, scale: 2, default: "0.0"
    t.decimal "deliver_time_rating", precision: 10, scale: 2, default: "0.0"
    t.decimal "service_quality_rating", precision: 10, scale: 2, default: "0.0"
    t.decimal "professionalism_rating", precision: 10, scale: 2, default: "0.0"
    t.boolean "post_payment"
    t.boolean "credit_payment"
    t.integer "credit_days"
    t.decimal "credit_limit"
    t.string "agami_kam_name"
    t.string "agami_kam_contact"
    t.string "agami_kam_email"
    t.string "delivery_responsibility"
    t.integer "product_lead_time"
    t.integer "return_days"
    t.string "email"
    t.text "address_line"
    t.integer "created_by_id"
    t.string "unique_id"
  end

  create_table "suppliers_variants", force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.bigint "supplier_id", null: false
    t.decimal "supplier_price", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_by_id"
    t.boolean "is_deleted", default: false
    t.index ["supplier_id"], name: "index_suppliers_variants_on_supplier_id"
    t.index ["variant_id"], name: "index_suppliers_variants_on_variant_id"
  end

  create_table "thanas", force: :cascade do |t|
    t.integer "district_id", null: false
    t.string "name", null: false
    t.string "bn_name", null: false
    t.boolean "is_deleted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "home_delivery", default: false
    t.integer "distributor_id"
  end

  create_table "third_party_logs", force: :cascade do |t|
    t.json "api_response"
    t.string "user_able_type"
    t.integer "user_able_id"
    t.boolean "status"
    t.text "api_request"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "third_party_users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.string "tenant"
    t.string "encrypted_password", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", default: 0
    t.integer "user_type", default: 0
  end

  create_table "user_modification_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "request_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.bigint "user_modify_reason_id", null: false
    t.text "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_by_id"
  end

  create_table "user_modify_reasons", force: :cascade do |t|
    t.string "title"
    t.string "title_bn"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "reason_type", default: 0
    t.integer "created_by_id"
  end

  create_table "user_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "default_delivery_method", default: 0
    t.integer "mail_notification", default: 0
    t.integer "smart_notification", default: 0
    t.integer "cellular_notification", default: 0
    t.integer "subscription", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_preferences_on_user_id"
  end

  create_table "user_promotions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "customer_order_id", null: false
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.boolean "used", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_order_id"], name: "index_user_promotions_on_customer_order_id"
    t.index ["user_id"], name: "index_user_promotions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "status", default: 0
    t.boolean "is_loyal", default: false
    t.integer "gender"
    t.integer "age"
    t.string "otp"
    t.string "registerable_type"
    t.integer "registerable_id"
    t.integer "user_type", default: 0
    t.integer "category", default: 0
    t.string "full_name", default: ""
    t.date "date_of_birth"
    t.string "temporary_otp"
    t.string "temporary_phone"
    t.string "verifiable_type"
    t.bigint "verifiable_id"
    t.datetime "verified_at"
    t.boolean "is_app_download"
    t.boolean "has_smart_phone"
    t.integer "partner_id"
    t.boolean "is_otp_verified", default: false, null: false
    t.boolean "is_deleted", default: false, null: false
    t.string "whatsapp"
    t.string "viber"
    t.string "imo"
    t.string "nid"
    t.string "home_address"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["verifiable_type", "verifiable_id"], name: "index_users_on_verifiable_type_and_verifiable_id"
  end

  create_table "variants", force: :cascade do |t|
    t.string "sku"
    t.float "weight"
    t.float "height"
    t.float "width"
    t.float "depth"
    t.datetime "deleted_at"
    t.integer "product_id"
    t.string "configuration"
    t.boolean "is_deleted", default: false
    t.boolean "primary", default: false
    t.decimal "price_distribution", precision: 10, scale: 2, default: "0.0"
    t.decimal "price_retailer", precision: 10, scale: 2, default: "0.0"
    t.decimal "price_consumer", precision: 10, scale: 2, default: "0.0", null: false
    t.string "sku_case_dimension", default: ""
    t.string "case_weight", default: "", null: false
    t.decimal "price_agami_trade", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "consumer_discount", precision: 10, scale: 2, default: "0.0"
    t.decimal "vat_tax", precision: 10, scale: 2, default: "0.0"
    t.decimal "effective_mrp", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "moq", precision: 10, scale: 2, default: "0.0"
    t.decimal "sku_case_width", precision: 10, scale: 2
    t.decimal "sku_case_length", precision: 10, scale: 2
    t.decimal "sku_case_height", precision: 10, scale: 2
    t.integer "last_item_index"
    t.string "weight_unit"
    t.string "height_unit"
    t.string "width_unit"
    t.string "depth_unit"
    t.string "sku_case_width_unit"
    t.string "sku_case_length_unit"
    t.string "sku_case_height_unit"
    t.string "case_weight_unit"
    t.string "code_by_supplier"
    t.integer "discount_type", default: 0
    t.integer "parent_id"
    t.integer "quantity", default: 0
    t.integer "bundle_status"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "created_by_id"
    t.decimal "b2b_price", default: "0.0"
    t.decimal "b2b_discount", precision: 10, scale: 2, default: "0.0"
    t.integer "b2b_discount_type", default: 0
    t.decimal "b2b_effective_mrp", precision: 10, scale: 2, default: "0.0"
    t.string "unique_id"
    t.index ["product_id"], name: "index_variants_on_product_id"
  end

  create_table "wallets", force: :cascade do |t|
    t.decimal "currency_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.string "currency_type", null: false
    t.string "walletable_type", null: false
    t.bigint "walletable_id", null: false
    t.index ["walletable_type", "walletable_id"], name: "index_wallets_on_walletable_type_and_walletable_id"
  end

  create_table "warehouse_bundles", force: :cascade do |t|
    t.integer "warehouse_id", null: false
    t.integer "bundle_id", null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "created_by_id"
  end

  create_table "warehouse_collect_histories", force: :cascade do |t|
    t.integer "warehouse_id"
    t.decimal "cash", default: "0.0"
    t.decimal "wallet", default: "0.0"
    t.integer "return", default: 0
    t.date "collect_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["warehouse_id", "collect_date"], name: "warehouse_date_index", unique: true
  end

  create_table "warehouse_margins", force: :cascade do |t|
    t.bigint "customer_order_id", null: false
    t.bigint "warehouse_id", null: false
    t.string "payable_type"
    t.integer "payable_id"
    t.datetime "paid_at"
    t.boolean "is_commissionable"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "amount", default: "0.0"
    t.index ["customer_order_id"], name: "index_warehouse_margins_on_customer_order_id"
    t.index ["warehouse_id"], name: "index_warehouse_margins_on_warehouse_id"
  end

  create_table "warehouse_storages", force: :cascade do |t|
    t.integer "warehouse_id", null: false
    t.string "name", null: false
    t.string "bn_name", null: false
    t.string "area", null: false
    t.string "location", null: false
    t.boolean "is_deleted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "warehouse_variants", force: :cascade do |t|
    t.integer "warehouse_id", null: false
    t.integer "variant_id", null: false
    t.integer "booked_quantity", default: 0, null: false
    t.integer "available_quantity", default: 0, null: false
    t.integer "packed_quantity", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "in_transit_quantity", default: 0
    t.integer "in_partner_quantity", default: 0
    t.integer "blocked_quantity", default: 0
    t.integer "created_by_id"
    t.integer "qc_pending_quantity", default: 0
    t.integer "qty_qc_failed_quantity", default: 0
    t.integer "qly_qc_failed_quantity", default: 0
    t.integer "location_pending_quantity", default: 0
    t.integer "return_in_partner_quantity", default: 0
    t.integer "return_in_transit_quantity", default: 0
    t.integer "return_qc_pending_quantity", default: 0
    t.integer "return_location_pending_quantity", default: 0
    t.integer "ready_to_ship_from_fc_quantity", default: 0
    t.integer "in_transit_to_dh_quantity", default: 0
    t.integer "ready_to_ship_quantity", default: 0
    t.integer "return_in_dh_quantity", default: 0
    t.integer "return_in_transit_to_fc_quantity", default: 0
    t.integer "return_qc_failed_quantity", default: 0
  end

  create_table "warehouse_variants_locations", force: :cascade do |t|
    t.integer "warehouse_variant_id"
    t.integer "location_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "quantity", default: 0
  end

  create_table "warehouses", force: :cascade do |t|
    t.string "name", null: false
    t.string "bn_name"
    t.string "warehouse_type", default: "distribution", null: false
    t.decimal "capacity", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email"
    t.string "encrypted_password"
    t.string "phone"
    t.boolean "is_deleted", default: false
    t.decimal "collected_cash_from_routes", default: "0.0"
    t.integer "return_count", default: 0
    t.boolean "public_visibility", default: true
    t.boolean "is_commission_applicable", default: true
    t.integer "status", default: 0
    t.string "code"
  end

  create_table "wh_purchase_orders", force: :cascade do |t|
    t.integer "supplier_id", null: false
    t.integer "order_by"
    t.decimal "quantity", precision: 8, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.boolean "is_deleted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order_status", default: 0
    t.integer "created_by_id"
    t.string "master_po_id"
    t.string "unique_id"
  end

  create_table "wishlists", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "product_id"
    t.index ["product_id"], name: "index_wishlists_on_product_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "aggregate_returns", "customer_orders"
  add_foreign_key "articles", "help_topics"
  add_foreign_key "attribute_set_product_attributes", "attribute_sets"
  add_foreign_key "attribute_set_product_attributes", "product_attributes"
  add_foreign_key "bank_transactions", "bank_accounts", column: "credit_bank_account_id"
  add_foreign_key "bank_transactions", "bank_accounts", column: "debit_bank_account_id"
  add_foreign_key "box_line_items", "boxes"
  add_foreign_key "box_line_items", "line_items"
  add_foreign_key "boxes", "dh_purchase_orders"
  add_foreign_key "brand_followings", "brands"
  add_foreign_key "brand_followings", "users"
  add_foreign_key "cart_promotions", "carts"
  add_foreign_key "cart_promotions", "promotions"
  add_foreign_key "company_assets", "asset_locations"
  add_foreign_key "company_assets", "oc_line_items"
  add_foreign_key "company_assets", "oc_products"
  add_foreign_key "customer_care_reports", "customer_orders"
  add_foreign_key "customer_order_promotions", "customer_orders"
  add_foreign_key "customer_order_promotions", "promotions"
  add_foreign_key "customer_order_status_changes", "customer_orders"
  add_foreign_key "customer_order_status_changes", "order_statuses"
  add_foreign_key "customer_orders", "warehouses"
  add_foreign_key "delivery_preferences", "users"
  add_foreign_key "districts", "warehouses"
  add_foreign_key "favorite_stores", "partners"
  add_foreign_key "favorite_stores", "users"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "invoices", "customer_orders"
  add_foreign_key "notifications", "users"
  add_foreign_key "oc_line_items", "oc_products"
  add_foreign_key "oc_line_items", "oc_purchase_orders"
  add_foreign_key "oc_purchase_orders", "oc_suppliers"
  add_foreign_key "payments", "customer_orders"
  add_foreign_key "product_categories", "categories"
  add_foreign_key "product_categories", "products"
  add_foreign_key "products", "attribute_sets"
  add_foreign_key "return_customer_orders", "customer_orders"
  add_foreign_key "return_customer_orders", "partners"
  add_foreign_key "return_customer_orders", "riders"
  add_foreign_key "return_customer_orders", "shopoth_line_items"
  add_foreign_key "return_customer_orders", "warehouses"
  add_foreign_key "return_status_changes", "return_customer_orders"
  add_foreign_key "reviews", "customer_orders"
  add_foreign_key "riders", "warehouses"
  add_foreign_key "suppliers_variants", "suppliers"
  add_foreign_key "suppliers_variants", "variants"
  add_foreign_key "user_preferences", "users"
  add_foreign_key "user_promotions", "customer_orders"
  add_foreign_key "user_promotions", "users"
  add_foreign_key "warehouse_margins", "customer_orders"
  add_foreign_key "warehouse_margins", "warehouses"
  add_foreign_key "wishlists", "products"
end
