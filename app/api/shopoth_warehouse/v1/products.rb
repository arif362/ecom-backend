# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class Products < ShopothWarehouse::Base
      include Grape::Kaminari
      require 'csv'
      # require_relative 'validations/validate_sku'
      helpers ::ShopothWarehouse::V1::NamedParams::Products

      helpers do
        def process_product_object_as_hash(product, staff)
          {
            product: product,
            warehouse: staff.warehouse,
          }
        end

        def json_response(product)
          product.as_json(
            except: [:created_at, :updated_at],
            include: [
              variants: {
                except: [:created_at, :updated_at],
                include: {
                  product_attribute_values:
                    {
                      except: [:created_at, :updated_at],
                      include: {
                        product_attribute: {
                          except: [:created_at, :updated_at]
                        }
                      }
                    }
                }
              },
              frequently_asked_questions: {
                except: [:created_at, :updated_at]
              },
              categories: {
                except: [:created_at, :updated_at]
              },
              product_types: {
                except: [:created_at, :updated_at]
              }
            ],
          ).merge(
            {
              hero_image: image_path(product.hero_image),
              hero_image_variant_path: image_variant_path(product.hero_image),
              images: image_paths(product.images),
              # images_variants_paths: image_variant_paths(product.images)
            },
          # {
          # product_attribute_images: product.product_attribute_images.map{
          #   |p_img|
          #   [
          #     {
          #       id: p_img.id,
          #       urls: image_paths(p_img.images),
          #       #variants_urls: image_variant_paths(p_img.images),
          #       is_default: p_img.is_default,
          #       product_attribute_value_id: p_img.product_attribute_value_id
          #     }
          #   ]
          # }
          # }, ***it has a problem, I will fix the error
          )
        end

        def json_response_with_list(products)
          p_arr = []
          products.each do |product|
            p_arr << json_response(product)
          end
          p_arr
        end

        def supplier_json_response(supplier_products)
          supplier_products.as_json(
            only: [:id, :title],
            include: [
              variants: {
                only: [:id, :sku],
                include: {
                  product_attribute_values:
                    {
                      only: [:value],
                    },
                },
              }
            ],
          )
        end

        def image_paths(img_arr)
          if img_arr.attached?
            new_arr = []
            img_arr.each do |img|
              path = img.service_url
              new_arr << path
            end
            return new_arr
          end
        end

        def image_path_for_attachment(image)
          image.service_url if image.present?
        end

        def attribute_images(images)
          arr ||= []
          images.each do |image|
            arr << { "id" => image.id,
                     "url" => image_path_for_attachment(image) }
          end
          arr
        end
      end

      resource :products do
        desc 'unique slug check'
        params do
          use :unique_slug_check_params
        end
        get '/slugs' do
          params[:slug] = params[:slug].present? ? params[:slug] : ''
          slug = if params[:id].present?
                   Product.where.not(id: params[:id]).where('LOWER(slug) = ?',
                                                            params[:slug].downcase.to_s.parameterize)
                 else
                   Product.where('LOWER(slug) = ?', params[:slug].downcase.to_s.parameterize)
                 end
          if slug.present?
            error!(failure_response_with_json('This slug already exists', HTTP_CODE[:UNPROCESSABLE_ENTITY],
                                              data = {}), HTTP_CODE[:OK])
          else
            success_response_with_json('Slug is unique', HTTP_CODE[:OK], data = {})
          end
        rescue StandardError => ex
          Rails.logger.info "Slug uniqueness check failed: #{__FILE__}, line - #{__LINE__} #{ex.message}"
          error!(failure_response_with_json('Something went wrong', HTTP_CODE[:UNPROCESSABLE_ENTITY],
                                            data = {}), HTTP_CODE[:OK])
        end

        desc 'get all deleted products'
        params do
          use :get_all_deleted_products_params
        end
        get 'deleted_list' do
          deleted_products = Product.unscoped.where(is_deleted: true)
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(deleted_products)), with: ShopothWarehouse::V1::Entities::ProductList
        rescue => ex
          error! respond_with_json("Unable to return product due to #{ex.message}", HTTP_CODE[:NOT_FOUND])
        end

        desc 'restore product'
        route_param :id do
          put 'restore_product' do
            product = Product.unscoped.find(params[:id])
            variants = product.variants.where(is_deleted: true)
            variants.update_all(is_deleted: false) if variants.present?
            product.update!(is_deleted: false)
            respond_with_json('product restored successfully', HTTP_CODE[:OK])
          rescue => ex
            error! respond_with_json("Unable to restore products due to #{ex.message}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        route_setting :authentication, optional: true
        get '/export_products' do
          offset = params[:offset]
          limit = params[:limit]
          products = Product.limit(limit).offset(offset).includes(:variants)
          present products, with: ShopothWarehouse::V1::Entities::ExportProducts
        end

        route_setting :authentication, optional: true
        get '/sync' do
          # products = Product.includes(:variants).where(status: [Product::STATUS[:new], Product::STATUS[:modified]])
          # present products, with: ShopothWarehouse::V1::Entities::ExportProducts
          variants = Variant.includes(:product)
          present variants, with: ShopothWarehouse::V1::Entities::ExportVariants
        end

        route_setting :authentication, optional: true
        post '/sync_callback' do
          products = Product.find(params[:ids])
          if products.present?
            products.each do |product|
              product.update_columns(status: nil)
            end
          end
        end

        desc 'Return the first 10 products based on title'
        params do
          use :first_10_products_based_on_title_params
        end

        get '/first_ten_products' do
          products = Product.search_by_title(params[:title]).limit(10)
          return products if products.present?

          []
        rescue StandardError => ex
          error! respond_with_json("Unable to fetch products with title: #{params[:title]} due to: #{ex.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc "First ten Product's by flag Search for assigning products into supplier_variant."
        params do
          use :search_for_assigning_products_into_supplier_variant_params
        end
        # First_ten_products for supplier_variant
        get '/search' do
          if params[:type] == 1
            supplier_products = Product.search_by_title(params[:search_string]).limit(10)
            supplier_json_response(supplier_products)
          else
            supplier_products = Product.search_by_title(params[:search_string]).limit(10)
            supplier_json_response(supplier_products)
            # TODO: Need to implement sku_search after changing sku type Integer to String.
            # sku_searched_product = Variant.search_by_sku(params[:search_string])
            # # supplier_new_products = Product.where(sku_searched_product[:product_id] == Product[:id])
            # # supplier_new_products.as_json(only: [:id, :title])
            # sku_searched_product.as_json(only: [:id])
          end
        rescue StandardError => ex
          error! respond_with_json("Unable to fetch products with title: #{params[:title]} due to: #{ex.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Sku search of variants.'
        get '/skus/search' do
          warehouse_id = check_dh_warehouse ? @current_staff.warehouse_id : ''
          variants = Variant.search_by_sku_or_supplier_code(params[:search_string].to_s.downcase, params[:order_type], warehouse_id).
                     includes(:product, :product_attribute_values, suppliers_variants: :supplier)
          response = if params[:order_type] == 'rto'
                       ShopothWarehouse::V1::Entities::TransferOrderVariants.represent(variants.limit(20), warehouse: @current_staff.warehouse)
                     else
                       ShopothWarehouse::V1::Entities::PurchaseOrderVariants.represent(variants.limit(20))
                     end

          present :item_count, variants.count
          present :variants, response
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch variants due to: #{error.message}"
          error!(respond_with_json("Unable to fetch variants due to: #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        get '/suppliers_variant/search' do
          if params[:type] == 1
            suppliers_variant_products = Product.search_by_title(params[:search_string]).limit(10)
            present suppliers_variant_products, with: ShopothWarehouse::V1::Entities::PurchaseOrderProducts
          else
            suppliers_variant_products = Product.search_by_title(params[:search_string]).limit(10)
            present suppliers_variant_products, with: ShopothWarehouse::V1::Entities::PurchaseOrderProducts
            # TODO: Need to implement sku_search after changing sku type Integer to String.
            # sku_searched_product = Variant.search_by_sku(params[:search_string])
            # # supplier_new_products = Product.where(sku_searched_product[:product_id] == Product[:id])
            # # supplier_new_products.as_json(only: [:id, :title])
            # sku_searched_product.as_json(only: [:id])
          end
        rescue StandardError => ex
          error! respond_with_json("Unable to fetch products with title: #{params[:title]} due to: #{ex.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Create a new product.'
        params do
          use :create_product_params
        end
        post do
          unless check_wh_warehouse
            error!(respond_with_json('Only central warehouse can create product.', HTTP_CODE[:FORBIDDEN]),
                   HTTP_CODE[:FORBIDDEN])
          end

          if params[:product][:product_features_attributes]&.size.to_i > 5
            error!(respond_with_json("You can't give more than 5 product features.", HTTP_CODE[:FORBIDDEN]),
                   HTTP_CODE[:FORBIDDEN])
          end

          if params[:product][:max_quantity_per_order].present? && !params[:product][:max_quantity_per_order].to_i.positive?
            error!(respond_with_json('Please give products quantity limit grater than 0.',
                                     HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:FORBIDDEN])
          end

          leaf_category = Category.find_by(id: params[:product][:leaf_category_id])
          unless leaf_category
            error!(respond_with_json('Leaf category not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          root_cat_id = Category.fetch_parent_category(leaf_category)
          unless root_cat_id
            error!(respond_with_json('Root category not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
          prod_attrs = params[:product].merge!(root_category_id: root_cat_id, created_by_id: @current_staff.id)
          prod_attrs[:variants_attributes] = prod_attrs[:variants_attributes].map do |variant|
            variant.merge!(created_by_id: @current_staff.id)
          end
          Product.create!(prod_attrs)
          respond_with_json('Successfully created product.', HTTP_CODE[:CREATED])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create product due to: #{error.message}"
          error!(respond_with_json("Unable to create product due to, #{error.message}.", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'bulk upload temporary image'
        post '/upload_temporary_image' do
          params do
            use :bulk_upload_temporary_image_params
          end
          tmp_images = BulkUploadTmpImage.add_image(params[:bulk_upload_tmp_image][:image_file])
          if tmp_images.present?
            present tmp_images, with: ShopothWarehouse::V1::Entities::TmpImageList
          else
            'Already stored the images you are trying to upload'
          end
        rescue => ex
          error!("Cannot create temporary image due to #{ex.message}")
        end

        desc 'Return list of temporary images'
        get '/temporary_image_list' do
          tmp_image_list = BulkUploadTmpImage.all.order('id DESC')
          present tmp_image_list, with: ShopothWarehouse::V1::Entities::TmpImageList
        rescue => ex
          error!("Unable to return temporary image list due to #{ex.message}")
        end

        desc 'Delete a specific bulk image'
        delete '/delete_temporary_image' do
          params do
            use :delete_a_specific_bulk_image_params
          end
          bulk_image = BulkUploadTmpImage.find_by(id: params[:image_id])
          bulk_image.destroy
        rescue => ex
          error!("Cannot delete product due to #{ex.message}")
        end

        desc 'import products'
        post '/import' do
          ProductManagement::ImportProductCSV.call(file: params[:file])
          'Products imported Successfully'
        rescue => ex
          error!("Cannot import product due to #{ex.message}")
        end

        desc 'export products'
        get '/export' do
          file_name = Product.to_csv
          if Rails.env.production?
            base_url = 'https://api.shopoth.com'
          else
            base_url = Rails.env.staging? ? 'http://api.shopoth.shop' : 'http://api.shopoth.net'
          end
          { file_path: "#{base_url}/exported_files/#{file_name}" }
        rescue => ex
          error!("Cannot export product due to #{ex.message}")
        end

        desc 'Update a specific product.'
        params do
          use :update_product_params
        end
        put ':id' do
          unless check_wh_warehouse
            error!(respond_with_json('Only central warehouse can update a product.', HTTP_CODE[:FORBIDDEN]),
                   HTTP_CODE[:FORBIDDEN])
          end

          product = Product.unscoped.where(is_deleted: false).find_by(id: params[:id])
          unless product
            error!(respond_with_json('Unable to find product.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          if params[:product][:max_quantity_per_order].present? && !params[:product][:max_quantity_per_order].to_i.positive?
            error!(respond_with_json('Please give products quantity limit grater than 0.',
                                     HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:FORBIDDEN])
          end

          if params[:product][:product_features_attributes]&.size.to_i > 5
            error!(respond_with_json("You can't give more than 5 product features.", HTTP_CODE[:FORBIDDEN]),
                   HTTP_CODE[:FORBIDDEN])
          end

          if params[:product][:meta_datum_attributes].present?
            meta_datum_id = product.meta_datum&.id
            params[:product][:meta_datum_attributes] = params[:product][:meta_datum_attributes].merge(id: meta_datum_id)
          end

          prod_attrs = params[:product]
          if params[:product][:leaf_category_id].present?
            leaf_cat = Category.find_by(id: params[:product][:leaf_category_id])
            unless leaf_cat
              error!(respond_with_json("Leaf category not found", HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            root_cat_id = Category.fetch_parent_category(leaf_cat)
            unless root_cat_id
              error!(respond_with_json("Root category not found", HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            prod_attrs = params[:product].merge(root_category_id: root_cat_id)
          end
          prod_attrs[:variants_attributes] = prod_attrs[:variants_attributes].map do |variant|
            variant['id'].present? ? variant : variant.merge!(created_by_id: @current_staff.id)
          end
          product.update!(prod_attrs)
          respond_with_json('Successfully updated product.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update product due to: #{error.message}"
          error!(respond_with_json("Unable to update product due to: #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Delete a specific product.'
        route_param :id do
          delete do
            product = Product.unscoped.where(is_deleted: false).find_by(id: params[:id])
            unless product.present?
              error!(respond_with_json('Product not found', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            if product.shopoth_line_items.present?
              error!(respond_with_json('This product is present in cart or customer orders',
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
            ActiveRecord::Base.transaction do
              if product.product_attribute_images.present?
                product.product_attribute_images.update_all(is_deleted: true)
              end
              var_attrs = ProductAttributeValuesVariant.where(variant_id: product.variants.ids)
              var_attrs.update_all(is_deleted: true) if var_attrs.present?
              suppliers_variants = SuppliersVariant.where(variant_id: product.variants.ids)
              suppliers_variants.update_all(is_deleted: true) if suppliers_variants.present?
              requested_variants = RequestedVariant.where(variant_id: product.variants.ids)
              requested_variants.update_all(is_deleted: true) if requested_variants.present?
              product.variants.update_all(is_deleted: true) if product.variants.present?
              product.update(is_deleted: true)
            end
            respond_with_json('Successfully deleted', HTTP_CODE[:OK])
          rescue => ex
            Rails.logger.info "Production deletion failed #{ex.message}"
            error!(respond_with_json('Unable to delete', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Delete a specific product attribute value image.'
        delete ':id/attribute_image' do
          attachment = ActiveStorage::Attachment.find_by(id: params[:id], record_type: 'ProductAttributeImage')
          unless attachment
            error!(respond_with_json('Attribute image not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
          attribute_image_record = ProductAttributeImage.find_by(id: attachment.record.id)
          attachment.destroy!
          attribute_image_record.delete if attribute_image_record.images.empty?
          respond_with_json('Successfully deleted attribute image.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to delete attribute image due to: #{error.message}"
          error!(respond_with_json('Unable to delete attribute image.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Delete a specific product image.'
        params do
          use :delete_a_specific_product_image_params
        end
        delete ':id/delete_image' do
          attachment = ActiveStorage::Attachment.find_by(id: params[:id].to_i, record_id: params[:product_id].to_i, record_type: 'Product')
          unless attachment
            error!(failure_response_with_json('Product image not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          attachment.destroy!
          success_response_with_json('Successfully deleted product image.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to delete product's image due to: #{error.message}"
          error!(failure_response_with_json("Unable to delete product's image.",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Return list of products.'
        params do
          use :list_of_product_params
        end
        get do
          products = Product.filter(params[:title], params[:brand], params[:category_id], params[:sub_category_id], params[:sku], params[:business_type])
          # TODO: Need to Optimize Query
          ShopothWarehouse::V1::Entities::ProductList.represent(paginate(Kaminari.paginate_array(products)))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to return product list due to: #{error.message}"
          error!(respond_with_json('Unable to return product list.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Return list of brands'
        get '/brands' do
          brands = Brand.all.order(created_at: :desc)
          brands.as_json(only: [:id, :name])
        rescue => ex
          error!("Unable to return product due to #{ex.message}")
        end

        desc 'Return a specific product details.'
        params do
          requires :id, type: String, allow_blank: false, desc: 'Product id'
        end

        get ':id' do
          product = Product.unscoped.where(is_deleted: false).find(params[:id])
          hash ||= []
          product&.product_attribute_images&.each do |attribute_image|
            found = hash.detect { |x| x['attribute']['id'] == attribute_image.product_attribute_value.product_attribute.id }
            if found.present?
              found['attribute_values'] << { 'id' => attribute_image.product_attribute_value.id,
                                             'value' => attribute_image.product_attribute_value.value,
                                             'bn_value' => attribute_image.product_attribute_value.bn_value,
                                             'attribute_image_id' => attribute_image.id,
                                             'images' => attribute_images(attribute_image.images), }
            else
              hash << { 'attribute' => { 'id' => attribute_image.product_attribute_value.product_attribute.id,
                                         'name' => attribute_image.product_attribute_value.product_attribute.name, },
                        'attribute_values' => [{ 'id' => attribute_image.product_attribute_value.id,
                                                 'value' => attribute_image.product_attribute_value.value,
                                                 'bn_value' => attribute_image.product_attribute_value.bn_value,
                                                 'attribute_image_id' => attribute_image.id,
                                                 'images' => attribute_images(attribute_image.images), }], }
            end
          end
          product_with_warehouse = product.as_json.merge(warehouse: @current_staff.warehouse).with_indifferent_access
          present product_with_warehouse, with: ShopothWarehouse::V1::Entities::Products
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch product details due to: #{error.message}"
          error!(respond_with_json('Unable to fetch product details.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        delete '/variant_delete/:id' do
          variant = Variant.find_by(id: params[:id])
          product = variant.product
          if product.variants.size == 1
            error!(respond_with_json('Can not delete this variant. At least one variant must exist',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
          variant.product_attribute_values_variants.update_all(is_deleted: true) if variant.product_attribute_values.present?
          variant.suppliers_variants.delete_all if variant.suppliers_variants.present?
          variant.update!(is_deleted: true)
          respond_with_json 'Successfully delete variant', HTTP_CODE[:OK]
        rescue => ex
          error!(respond_with_json("Unable to delete variant due to #{ex.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # /variants/search?sku=value
        desc 'Search variants with SKU'
        get 'variants/search' do
          variants = Variant.search_by_sku(params[:sku])
          present variants, with: ShopothWarehouse::V1::Entities::SkuDetails
        end

        desc 'Product Changes Log'
        get ':id/changes_log' do
            product = Product.unscoped.find_by(id: params[:id])
            unless product
              Rails.logger.info 'Unable to fetch product'
              error!(failure_response_with_json('Unable to fetch product', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            changes_log = product.audits
            success_response_with_json('Successfully fetched product changes log', HTTP_CODE[:OK],
                                       ShopothWarehouse::V1::Entities::ProductLog.represent(changes_log))
          rescue StandardError => error
            Rails.logger.info "#{__FILE__} \nUnable to fetch product changes log due to, #{error.message}"
            error!(failure_response_with_json("Unable to fetch product changes log due to, #{error.message}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

        desc 'Product Category Changes Log'
        params do
          use :category_changes_log_params
        end
        get ':id/categories_log' do
          product_category = Product.unscoped.find_by(id: params[:id]).product_categories

          unless product_category
            Rails.logger.info 'Unable to fetch product category'
            error!(failure_response_with_json('Unable to fetch product category', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
          # TODO: Need to Optimize Query
          changes_log = paginate(Kaminari.paginate_array(
                                   Audited::Audit.where(auditable_type: 'ProductCategory',
                                                        auditable_id: product_category.map(&:id)).order(id: :desc)))
          success_response_with_json('Successfully fetched product category changes log', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::AuditLogs.represent(changes_log))
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to fetch product category changes
                                          log due to, #{error.message}"
          error!(failure_response_with_json("Unable to fetch product category changes
                                            log due to, #{error.message}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
