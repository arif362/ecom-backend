module ProductManagement
  class ImportProductCSV
    include Interactor
    require 'csv'

    delegate :file, to: :context

    def call
      import(file)
    end

    private

    def import(file)
      variants_attributes = {}
      orginal_product = {}
      CSV.foreach(file[:tempfile].path, headers: true) do |p_hash|
        tmp_product_id = p_hash.fetch('product_id')
        parent_id = p_hash.fetch('parent_id')
        product_title = p_hash.fetch('title')
        if tmp_product_id.present? && check_product_params(p_hash)
          product = Product.new
          product.title = product_title
          product.description = p_hash.fetch('full_description')
          product.bn_title = ''
          product.bn_description = ''
          product.short_description = p_hash.fetch('short_description')
          product.bn_short_description = ''
          product.warranty_period = p_hash.fetch('warranty_period')
          product.warranty_policy = p_hash.fetch('warranty_policy')
          product.bn_warranty_policy = ''
          product.inside_box = p_hash.fetch('inside_box')
          product.bn_inside_box = ''
          product.video_url = p_hash.fetch('video_url')
          product.warranty_type = p_hash.fetch('warranty_type')
          product.dangerous_goods = p_hash.fetch('dangerous_goods')
          product.sku_type = p_hash.fetch('sku_type')
          product.warranty_period_type = take_warranty_period_type(p_hash.fetch('warranty_period_type'))
          product.company = p_hash.fetch('company')
          product.bn_company = ''
          product.brand = p_hash.fetch('brand')
          product.bn_brand = ''
          product.certification = p_hash.fetch('certification')
          product.bn_certification = ''
          product.license_required = p_hash.fetch('license_required')
          product.material = p_hash.fetch('material')
          product.bn_material = ''
          product.consumption_guidelines = p_hash.fetch('consumption_guidelines')
          product.bn_consumption_guidelines = ''
          product.temperature_requirement = p_hash.fetch('temperature_requirement')
          product.bn_temperature_requirement = ''
          product.keywords = p_hash.fetch('keywords')
          product.brand_message = p_hash.fetch('brand_message')
          product.tagline = p_hash.fetch('tagline')
          product.product_type = p_hash.fetch('product_type')
          product.main_image.attach(take_main_image(p_hash.fetch('main_image')))
          take_product_images(p_hash.fetch('product_images')).each do |image|
            product.images.attach(image)
          end
          if product.save!
            delete_single_tmp_image(p_hash.fetch('main_image')) if product.main_image.attached?
            delete_tmp_images(p_hash.fetch('product_images')) if product.images.attached?
          end

          orginal_product[tmp_product_id] = product
          add_faq(p_hash, product)
          add_category(p_hash, product)
          add_offer_type(p_hash, product)
          add_pro_attr_images_attrs(p_hash.fetch('attribute_images_by'), p_hash.fetch('attribute_images'), product)
        elsif parent_id.present?
          product = orginal_product[parent_id]
          variants_attributes[:sku] = p_hash.fetch('va_sku').present? ? p_hash.fetch('va_sku') : 'n/a'
          variants_attributes[:weight] = p_hash.fetch('va_weight')
          variants_attributes[:height] = p_hash.fetch('va_height')
          variants_attributes[:width] = p_hash.fetch('va_width')
          variants_attributes[:depth] = p_hash.fetch('va_depth')
          variants_attributes[:price_distribution] = p_hash.fetch('va_price_distribution')
          variants_attributes[:price_retailer] = p_hash.fetch('va_price_retailer')
          variants_attributes[:price_consumer] = p_hash.fetch('va_price_consumer').present? ? p_hash.fetch('va_price_consumer') : 0.0
          variants_attributes[:consumer_discount] = p_hash.fetch('va_consumer_discount')
          variants_attributes[:sku_case_dimension] = p_hash.fetch('va_sku_case_dimension')
          variants_attributes[:case_weight] = p_hash.fetch('va_case_weight')
          variants_attributes[:price_agami_trade] = p_hash.fetch('va_price_agami_trade').present? ? p_hash.fetch('va_price_agami_trade') : 0.0
          variants_attributes[:vat_tax] = p_hash.fetch('va_vat_tax')
          variants_attributes[:effective_mrp] = p_hash.fetch('va_effective_mrp').present? ? p_hash.fetch('va_effective_mrp') : 0.0
          variants_attributes[:moq] = p_hash.fetch('va_moq')
          variants_attributes[:sku_case_width] = p_hash.fetch('va_sku_case_width')
          variants_attributes[:sku_case_length] = p_hash.fetch('va_sku_case_length')
          variants_attributes[:sku_case_height] = p_hash.fetch('va_sku_case_height')
          variants_attributes[:weight_unit] = p_hash.fetch('va_weight_unit')
          variants_attributes[:height_unit] = p_hash.fetch('va_height_unit')
          variants_attributes[:width_unit] = p_hash.fetch('va_width_unit')
          variants_attributes[:depth_unit] = p_hash.fetch('va_depth_unit')
          variants_attributes[:sku_case_width_unit] = p_hash.fetch('va_sku_case_width_unit')
          variants_attributes[:sku_case_length_unit] = p_hash.fetch('va_sku_case_length_unit')
          variants_attributes[:sku_case_height_unit] = p_hash.fetch('va_sku_case_height_unit')
          variants_attributes[:case_weight_unit] = p_hash.fetch('va_case_weight_unit')
          variants_attributes[:primary] = p_hash.fetch('va_make_default').present? ? true : false
          # variant create
          if product.present? && check_variant_params(p_hash)
            variant = product.variants.create!(variants_attributes)
          else
            variant = nil
          end
          add_product_configuration(variant, p_hash.fetch('va_configuration')) if variant.present?
        end
      end
    end

    def add_product_configuration(variant, product_attr_values)
      return if product_attr_values.blank?
      product_attr_values.split(',').each do |product_attribute|
        product_attr_value = product_attribute.split(':')
        attribute_name = product_attr_value.first
        attribute_value = product_attr_value.last
        attribute = ProductAttribute.find_by(name: attribute_name)
        attribute_value = attribute.present? ? attribute.product_attribute_values.find_by(value: attribute_value) : nil
        variant.product_attribute_values_variants.create!(product_attribute_value_id: attribute_value.id) if attribute_value.present?
      end
    end

    def add_faq(p_hash, product)
      (1..3).each do |index|
        if p_hash.fetch("fa_question_#{index}").present?
          return unless check_faq_params(p_hash, index)
          product.frequently_asked_questions.create!({
                                                       question: p_hash.fetch("fa_question_#{index}"),
                                                       bn_question: '',
                                                       answer: p_hash.fetch("fa_answer_#{index}"),
                                                       bn_answer: ''
                                                     })
        end
      end
    end

    def add_category(p_hash, product)
      if p_hash.fetch('parent_category').present?
        category = Category.find_by(title: p_hash.fetch('parent_category'), parent_id: nil)
        unless category.present?
          category = Category.create!(title: p_hash.fetch('parent_category'), bn_title: 'n/a', parent_id: nil)
        end
        product.product_categories.create!(category_id: category.id)
      else
        category = nil
      end
      if category.present? && p_hash.fetch('sub_category').present?
        sub_category = Category.find_by(title: p_hash.fetch('sub_category'), parent_id: category.id)
        if sub_category.blank?
          sub_category = Category.create!(title: p_hash.fetch('sub_category'), bn_title: 'n/a', parent_id: category.id)
        end
        product.product_categories.create!(category_id: sub_category.id)
      else
        sub_category = nil
      end
      if sub_category.present? && p_hash.fetch('sub_sub_category').present?
        sub_sub_category = Category.find_by(title: p_hash.fetch('sub_sub_category'), parent_id: sub_category.id)
        unless sub_sub_category.present?
          sub_sub_category = Category.create!(title: p_hash.fetch('sub_sub_category'), bn_title: 'n/a', parent_id: sub_category.id)
        end
        product.product_categories.create!(category_id: sub_sub_category.id)
      end
    end

    def add_offer_type(p_hash, product)
      return if p_hash.fetch('offer_type').blank?
      # TODO: have to change model name cause - product type has been changed as offer_type
      # from front end but offer_type is acting as product type in backend
      product_type = ProductType.find_by(title: p_hash.fetch('offer_type'))
      product.products_product_types.create!(product_id: product.id, product_type_id: product_type.id) if product_type.present?
    end

    def add_pro_attr_images_attrs(attribute_images_by, attribute_img_vals, product)
      return unless attribute_images_by.present? && attribute_img_vals.present?
      product_attribute = ProductAttribute.find_by(name: attribute_images_by)
      attribute_img_vals.split('|').each do |attribute_values|
        product_attr_value = attribute_values.split(':')
        pro_attr_val_name = product_attr_value.first
        pro_attr_val_images = product_attr_value.last
        product_attribute_value = product_attribute.present? ? product_attribute.product_attribute_values.find_by(value: pro_attr_val_name) : nil
        if product_attribute_value.present?
          product_attr_image = product.product_attribute_images.create!(product_attribute_value_id: product_attribute_value.id)
        else
          product_attr_image = nil
        end
        if product_attr_image.present? && pro_attr_val_images.present?
          take_pro_attr_images(pro_attr_val_images, product_attr_image)
        end
      end
    end

    def add_product_attribute_value(p_hash, variant)
      if p_hash.fetch('product_attribute_name').present?
        product_attribute = ProductAttribute.find_or_create_by!(name: p_hash.fetch('product_attribute_name'), bn_name: '')
      else
        product_attribute = nil
      end

      if product_attribute.present? && p_hash.fetch('product_attribute_value').present?
        product_attribute_value = product_attribute.product_attribute_values.find_or_create_by!(value: p_hash.fetch('product_attribute_value'), bn_value: '')
        variant.product_attribute_values_variants.create!(variant_id: variant.id, product_attribute_value_id: product_attribute_value.id)
      end
    end

    def take_warranty_period_type(warranty_period_type)
      return if warranty_period_type.blank?
      warranty_period_type == 'months' ? 1 : 2
    end

    def take_main_image(tmp_img_file_name)
      return if tmp_img_file_name.blank?
      bulk_upload_tmp_obj = BulkUploadTmpImage.find_by(file_name: tmp_img_file_name)
      bulk_upload_tmp_obj.present? ? bulk_upload_tmp_obj.image.blob : nil
    end

    def take_product_images(tmp_pro_img_names)
      return [] if tmp_pro_img_names.blank?
      bulk_upload_tmp_obj_images = []
      tmp_pro_img_names.split(',').each do |tmp_img_file_name|
        bulk_upload_tmp_obj = BulkUploadTmpImage.find_by(file_name: tmp_img_file_name)
        if bulk_upload_tmp_obj.present?
          bulk_upload_tmp_obj_image = bulk_upload_tmp_obj.image.blob
          bulk_upload_tmp_obj_images << bulk_upload_tmp_obj_image
        end
      end
      bulk_upload_tmp_obj_images
    end

    def take_pro_attr_images(tmp_pro_img_names, product_attr_image)
      return [] if tmp_pro_img_names.blank?
      tmp_pro_img_names.split(',').each do |tmp_img_file_name|
        bulk_upload_tmp_obj = BulkUploadTmpImage.find_by(file_name: tmp_img_file_name)
        if bulk_upload_tmp_obj.present?
          bulk_upload_tmp_obj_image = bulk_upload_tmp_obj.image.blob
          product_attr_image.images.attach(bulk_upload_tmp_obj_image)
          delete_single_tmp_image(tmp_img_file_name) if product_attr_image.images.attached?
        end
      end
    end

    def delete_single_tmp_image(tmp_img_file_name)
      return if tmp_img_file_name.blank?
      bulk_upload_tmp_obj = BulkUploadTmpImage.find_by(file_name: tmp_img_file_name)
      bulk_upload_tmp_obj.destroy if bulk_upload_tmp_obj.present?
    end

    def delete_tmp_images(tmp_pro_img_names)
      return if tmp_pro_img_names.blank?
      tmp_pro_img_names.split(',').each do |tmp_img_file_name|
        bulk_upload_tmp_obj = BulkUploadTmpImage.find_by(file_name: tmp_img_file_name)
        bulk_upload_tmp_obj.destroy if bulk_upload_tmp_obj.present?
      end
    end

    def check_product_params(p_hash)
      flag = false
      return flag if p_hash.fetch('title').blank?
      return flag if p_hash.fetch('company').blank?
      return flag if p_hash.fetch('brand').blank?
      return flag if p_hash.fetch('main_image').blank?
      !flag
    end

    def check_variant_params(p_hash)
      flag = false
      return flag if p_hash.fetch('va_sku').blank?
      return flag if p_hash.fetch('va_weight').blank?
      return flag if p_hash.fetch('va_height').blank?
      return flag if p_hash.fetch('va_width').blank?
      return flag if p_hash.fetch('va_price_distribution').blank?
      return flag if p_hash.fetch('va_price_retailer').blank?
      return flag if p_hash.fetch('va_price_consumer').blank?
      return flag if p_hash.fetch('va_sku_case_width').blank?
      return flag if p_hash.fetch('va_sku_case_length').blank?
      return flag if p_hash.fetch('va_sku_case_height').blank?
      return flag if p_hash.fetch('va_case_weight').blank?
      return flag if p_hash.fetch('va_price_agami_trade').blank?
      return flag if p_hash.fetch('va_vat_tax').blank?
      return flag if p_hash.fetch('va_effective_mrp').blank?
      return flag if p_hash.fetch('va_moq').blank?
      !flag
    end

    def check_faq_params(p_hash, index)
      flag = false
      return flag if p_hash.fetch("fa_question_#{index}").blank?
      # return flag if p_hash.fetch("fa_bn_question_#{index}").blank?
      return flag if p_hash.fetch("fa_answer_#{index}").blank?
      # return flag if p_hash.fetch("fa_bn_answer_#{index}").blank?
      !flag
    end

    def check_p_attribute_params(product_attribute)
      flag = false
      return flag if product_attribute.value.blank?
      !flag
    end

  end

end
