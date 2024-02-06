# frozen_string_literal: true

if @error.blank?
  if categories.present?
    json.categories do
      json.array! categories do |category|
        json.id category.id
        json.title category.title
        json.bn_title category.bn_title
        json.description category.description
        json.bn_description category.bn_description
        json.image_file image_path(category.image)
        json.home_page_visibility category.home_page_visibility
        json.sub_categories category.sub_categories do |sub_category|
          json.id sub_category.id
          json.title sub_category.title
          json.bn_title sub_category.bn_title
          json.description sub_category.description
          json.bn_description sub_category.bn_description
          json.parent_id sub_category.parent.id
          json.image_file image_path(sub_category.image)
          json.home_page_visibility sub_category.home_page_visibility
          json.sub_sub_categories sub_category.sub_categories do |sub_sub_category|
            json.id sub_sub_category.id
            json.title sub_sub_category.title
            json.bn_title sub_sub_category.bn_title
            json.description sub_sub_category.description
            json.bn_description sub_sub_category.bn_description
            json.parent_id sub_sub_category.parent.id
            json.grand_parent_id sub_sub_category.parent.parent.id
            json.image_file image_path(sub_sub_category.image)
            json.home_page_visibility sub_sub_category.home_page_visibility
          end
        end
      end
    end
  else
    json.data({})
  end
end
