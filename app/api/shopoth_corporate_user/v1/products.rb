# frozen_string_literal: true

module ShopothCorporateUser
  module V1
    class Products < ShopothCorporateUser::Base
      include Grape::Kaminari

      helpers do
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
            ]
          ).merge(
            {
              hero_image: image_path(product.hero_image),
              hero_image_variant_path: image_variant_path(product.hero_image),
              images: image_paths(product.images),
            },
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
      end

      resource :products do
        desc 'Return list of products'
        params do
          use :pagination, per_page: 20, max_per_page: 30, offset: 0
        end
        get do
          products = Product.all.order("id DESC")
          present paginate(products), with: ShopothWarehouse::V1::Entities::ProductList
        rescue => ex
          error!("Unable to return product due to #{ex.message}")
        end

        desc 'Return a product'
        params do
          requires :id, type: String, allow_blank: false, desc: 'Product id'
        end

        get ':id' do
          product = Product.find(params[:id])
          hash ||= []
          product&.product_attribute_images&.each do |attribute_image|
            found = hash.find{|x| x["attribute"] == attribute_image.product_attribute_value.product_attribute.name}
            if found.present?
              found["attribute_values"] << { "value" => attribute_image.product_attribute_value.value,
                                             "bn_value" => attribute_image.product_attribute_value.bn_value,
                                             "images" => image_paths(attribute_image.images) }
            else
              hash << {"attribute" => attribute_image.product_attribute_value.product_attribute.name,
                       "attribute_values"=> [{ "value" => attribute_image.product_attribute_value.value,
                                              "bn_value" => attribute_image.product_attribute_value.bn_value,
                                              "images" => image_paths(attribute_image.images) }]}
            end
          end
          product_json = ApplicationController.render 'api/products/show',
                         locals: { product: product, product_attributes: hash }
          JSON.parse(product_json)
        rescue => ex
          error!("Unable to find product due to #{ex.message}")
        end
      end
    end
  end
end
