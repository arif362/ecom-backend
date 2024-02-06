module ApplicationHelper
  include Rails.application.routes.url_helpers

  def image_path(obj)
    obj.service_url if obj.attached?
  end

  def image_variant_path(obj)
    {
     mini_img: obj.variant(Product.sizes[:mini]).processed.service_url,
     small_img: obj.variant(Product.sizes[:small]).processed.service_url,
     product_img: obj.variant(Product.sizes[:product]).processed.service_url,
     large_img: obj.variant(Product.sizes[:large]).processed.service_url
    } if obj.attached?
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
end