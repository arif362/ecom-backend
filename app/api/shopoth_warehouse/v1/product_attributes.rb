# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class ProductAttributes < ShopothWarehouse::Base

      helpers do
        def json_response(product_attributes)
          product_attributes.as_json(
            except: [:created_at, :updated_at],
            include: {
              product_attribute_values: {
                except: [:created_at, :updated_at]
              }
            }
          )
        end

        def create_product_attribute_value(product_attribute_unique_id, attribute_value)
          product_attribute_value = {
            value: attribute_value,
            unique_id: SecureRandom.uuid,
            attribute_id: product_attribute_unique_id,
          }
          response = Thanos::ProductAttributeValue.create(product_attribute_value)
          if response[:error].present?
            error!(respond_with_json("Product attribute value create error response: #{response[:error_descrip]}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
          product_attribute_value
        end
      end

      resource :product_attributes do

        params do
          use :pagination, per_page: 50
        end
        desc 'Return list of product attributes'
        get do
          product_attributes = ProductAttribute.all
          # TODO: Need to Optimize Query
          json_response(paginate(Kaminari.paginate_array(product_attributes)))
        rescue ::ActiveRecord::ActiveRecordError => e
          {message: "Unable to find records"}
        end

        desc 'Return a product attribute'
        get ':id', jbuilder: 'product_attribute/show' do
          product_attribute = ProductAttribute.find(params[:id])
          if product_attribute.present?
            json_response(product_attribute)
          else
            raise Base::HTTP_ERROR[404]
          end
        rescue ::ActiveRecord::ActiveRecordError => e
          {message: "Unable to find record with id #{params[:id]}"}
        end

        params do
          requires :product_attribute, type: Hash do
            requires :name, type: String
            optional :bn_name, type: String
            requires :product_attribute_values_attributes, type: Array do
              requires :value, type: String
              optional :bn_value, type: String
            end
          end
        end

        desc 'create a new product attribute'
        post do
          unless ProductAttribute.find_by(name: params[:product_attribute][:name]).blank?
            error!(respond_with_json("Product attribute with the name, #{params[:product_attribute][:name]}
                                      already exists",
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end
          product_attribute = ProductAttribute.create(
            name: params[:product_attribute][:name],
            bn_name: params[:product_attribute][:bn_name],
            created_by_id: @current_staff.id,
          )
          params[:product_attribute][:product_attribute_values_attributes].each do |value|
            product_attribute_value = create_product_attribute_value(product_attribute.unique_id, value[:value])
            product_attribute.product_attribute_values.create(
              value: value[:value],
              bn_value: value[:bn_value],
              unique_id: product_attribute_value[:unique_id],
            )
          end
          json_response(product_attribute)
        rescue StandardError => ex
          error!(respond_with_json("Cannot create product attribute due to #{ex.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Update a specific product attribute'
        route_param :id do
          put do
            product_attribute = ProductAttribute.find(params[:id])
            params[:product_attribute][:product_attribute_values_attributes].each do |attr_value|
              value = product_attribute.product_attribute_values&.find_by(id: attr_value[:id])
              if value.blank?
                product_attribute_value = create_product_attribute_value(product_attribute.unique_id, attr_value[:value])
                product_attribute.product_attribute_values.create(
                  value: attr_value[:value],
                  bn_value: attr_value[:bn_value],
                  unique_id: product_attribute_value[:unique_id],
                )
              elsif attr_value[:is_deleted] == true
                if value.product_attribute_values_variants.present?
                  error!(respond_with_json('Sorry attribute values can not be deleted.
                           This is associated with variants. Remove them first.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                         HTTP_CODE[:UNPROCESSABLE_ENTITY])
                end
                response_delete = Thanos::ProductAttributeValue.delete(value)
                if response_delete[:error].present?
                  error!(respond_with_json("Product attribute value delete error response: #{response[:error_descrip]}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                         HTTP_CODE[:UNPROCESSABLE_ENTITY])
                end
                value.update(is_deleted: true)
              else
                value.update(
                  bn_value: attr_value[:bn_value].present? ? attr_value[:bn_value] : value.bn_value,
                )
              end
            end
            product_attribute_request = {
              id: product_attribute.id,
              name: params[:product_attribute][:name],
              unique_id: product_attribute.unique_id,
              created_by_id: product_attribute.created_by_id,
            }
            product_attribute_response = Thanos::ProductAttribute.update(product_attribute_request)
            if product_attribute_response[:error].present?
              error!(respond_with_json("Product attribute error response: #{response[:error_descrip]}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
            product_attribute.update(
              name: params[:product_attribute][:name],
              bn_name: params[:product_attribute][:bn_name].present? ? params[:product_attribute][:bn_name] : product_attribute.bn_name,
            )
            product_attribute_json =
              ApplicationController.render 'api/product_attributes/update_response',
                                           locals: { product_attribute: product_attribute}
            JSON.parse(product_attribute_json)
          rescue StandardError => ex
            error!(respond_with_json("Cannot update product attribute due to #{ex.message}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Delete a specific product attribute.'
        route_param :id do
          delete do
            product_attribute = ProductAttribute.find_by(id: params[:id])
            if product_attribute.product_attribute_images.present? || product_attribute.product_attribute_values_variants.present?
              error!(respond_with_json("Can't delete attribute, it has associated variants or images. Please delete those first.",
                                       HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:FORBIDDEN])
            end

            attribute_value = product_attribute.name
            ActiveRecord::Base.transaction do
              response1 = Thanos::ProductAttribute.delete(product_attribute)
              if response1[:error].present?
                error!(respond_with_json("Product attribute error response: #{response1[:error_descrip]}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                       HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
              product_attribute.product_attribute_values.each do |product_attribute_value|
                response2 = Thanos::ProductAttributeValue.delete(product_attribute_value)
                if response2[:error].present?
                  error!(respond_with_json("Product attribute value error response: #{response2[:error_descrip]}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                         HTTP_CODE[:UNPROCESSABLE_ENTITY])
                end
              end
              product_attribute.product_attribute_values.update_all(is_deleted: true)
              product_attribute.update_columns(is_deleted: true)
              respond_with_json("Successfully deleted product attribute #{attribute_value}", HTTP_CODE[:OK])
            end

          rescue StandardError => ex
            error!("Cannot delete product attribute due to #{ex.message}")
          end
        end
      end
    end
  end
end
