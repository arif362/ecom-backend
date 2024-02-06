# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class AttributeSets < ShopothWarehouse::Base

      helpers do
        def json_response(product_attributes)
          product_attributes.as_json(
            except: [:created_at, :updated_at],
            include: {
              product_attributes: {
                except: [:created_at, :updated_at],
                include: {
                  product_attribute_values: {
                      except: [:created_at, :updated_at]
                  }
                }
              }
            },
          )
        end
      end

      resource :attribute_sets do

        params do
          use :pagination, per_page: 50
        end
        desc 'Return list of product attribute sets'
        get do
          attribute_sets = AttributeSet.all
          # TODO: Need to Optimize Query
          success_response_with_json('Successfully fetched all attribute sets', HTTP_CODE[:OK], json_response(paginate(Kaminari.paginate_array(attribute_sets))))
        rescue ::ActiveRecord::ActiveRecordError => error
          failure_response_with_json("Unable to find records due to #{error}", HTTP_CODE[:NOT_FOUND])
        end

        desc 'Return a product attribute set'
        get ':id' do
          attribute_set = AttributeSet.find(params[:id])
          if attribute_set.present?
            success_response_with_json('Successfully fetched attribute set', HTTP_CODE[:OK], json_response(attribute_set))
          else
            raise Base::HTTP_ERROR[404]
          end
        rescue ::ActiveRecord::ActiveRecordError => error
          failure_response_with_json("Unable to find record due to #{error}", HTTP_CODE[:NOT_FOUND])
        end

        params do
          requires :title, type: String
          requires :product_attribute_ids, type: Array
        end

        desc 'Create a new attribute set.'
        post do
          ActiveRecord::Base.transaction do
            attribute_set = AttributeSet.create!(title: params[:title], created_by_id: @current_staff.id)
            params[:product_attribute_ids].each do |attribute_id|
              attribute = ProductAttribute.find_by(id: attribute_id.to_i)
              unless attribute
                failure_response_with_json("Product attribute id #{attribute_id} is not found", HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
              attribute.attribute_set_product_attributes.create!(attribute_set_id: attribute_set.id, created_by_id: @current_staff.id)
            end
            Thanos::AttributeSet.create(attribute_set,
                                        attribute_set.product_attributes.map(&:unique_id).split(',').join(','))

            success_response_with_json('Successfully created attribute set', HTTP_CODE[:CREATED], json_response(attribute_set))
          end

        rescue StandardError => error
          failure_response_with_json("Cannot create attribute set due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Update a specific attribute set.'
        route_param :id do
          put do
            attribute_set = AttributeSet.find(params[:id])
            response = Thanos::AttributeSet.update(attribute_set,
                                                   attribute_set.product_attributes.map(&:unique_id).split(',').join(','))
            if response[:error].present?
              error!(respond_with_json("Attribute set error response: #{response[:error_descrip]}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
            attribute_set.update(title: params[:title])
            AttributeSetProductAttribute.where(attribute_set: attribute_set).delete_all
            params[:product_attribute_ids].each do |attribute_id|
              attribute_set.attribute_set_product_attributes.create!(product_attribute_id: attribute_id)
            end
            success_response_with_json('Successfully updated attribute set', HTTP_CODE[:OK], json_response(attribute_set))
          rescue StandardError => error
            failure_response_with_json("Cannot update attribute set due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Delete a specific attribute set.'
        route_param :id do
          delete do
            attribute_set = AttributeSet.find(params[:id])
            if attribute_set.products.present?
              error!(respond_with_json("Can't delete attribute set, it has associated products. Please delete those first.", HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:FORBIDDEN])
            end

            attribute_set.destroy!
            respond_with_json("Successfully deleted attribute set #{attribute_set}", HTTP_CODE[:OK])
          rescue StandardError => error
            failure_response_with_json("Cannot delete attribute set due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
