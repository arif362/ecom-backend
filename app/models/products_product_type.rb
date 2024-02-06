class ProductsProductType < ApplicationRecord
  audited
  belongs_to :product
  belongs_to :product_type

  after_save :check_bundle

  def check_bundle
    if product_type.slug == ProductCategoryList::PRODUCT_TYPES[:bundles] && !product.bundle_product?
      destroy
      fail 'Only bundle product can have bundles offer type'
    end
  end
end
