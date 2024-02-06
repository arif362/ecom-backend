# frozen_string_literal: true

module Finance
  module V1
    class Variants < Finance::Base
      resource :variants do
        desc 'SKU search'
        get 'skus_search' do
          search_string = params[:search_string].present? ? params[:search_string].downcase : ''
          variants = Variant.search_by_sku_or_supplier_code(search_string).
                     includes(:product, :product_attribute_values, suppliers_variants: :supplier)
          item_count = variants.count
          present :item_count, item_count
          present :variants, variants.limit(20), with: ShopothWarehouse::V1::Entities::PurchaseOrderVariants
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to search: #{error.message}"
          error!(respond_with_json('Unable to search',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
