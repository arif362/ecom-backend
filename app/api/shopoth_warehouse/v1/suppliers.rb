# frozen_string_literal: true

module ShopothWarehouse
  module V1
    # rubocop:disable Style/Documentation
    class Suppliers < ShopothWarehouse::Base
      helpers do
        def supplier_address(address)
          {
            address: {
              district: address.district,
              thana: address.thana,
              area: address.area,
              address_line: address.address_line,
              bn_address_line: address.bn_address_line,
              phone: address.phone,
              bn_phone: address.bn_phone,
              is_deleted: address.is_deleted,
            },
          }.as_json
        end

        def product_attribute_values(variant)
          variant.product_attribute_values.map do |attr_val|
            {
              value: attr_val.value,
            }
          end
        end

      end
      resource :suppliers do
        # INDEX
        params do
          use :pagination, per_page: 50
        end
        desc 'Get all suppliers'
        get do
          if check_wh_warehouse
            suppliers = if params[:name].present?
                          Supplier.search_by_name(params[:name]).order(created_at: :desc)
                        else
                          Supplier.order(created_at: :desc)
                        end
            # TODO: Need to Optimize Query
            ShopothWarehouse::V1::Entities::Suppliers.represent(
              paginate(Kaminari.paginate_array(suppliers)),
            )
          else
            error!(respond_with_json('Not Allowed', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue StandardError => error
          error!(respond_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        params do
          requires :supplier, type: Hash do
            # requires :company, type: String, description: 'Company name'
            # requires :bn_company, type: String, description: 'Company name in bangla'
            optional :email, type: String, description: 'Company email'
            optional :phone, type: String, description: 'Company phone [optional]'
            optional :bn_phone, type: String, description: 'Bangla company phone [optional]'
            # optional :contact_person, type: String, description: 'Company contact person'
            # optional :contact_person_email, type: String, description: 'Company contact person email'
            # optional :contact_person_phone, type: String, description: 'Company contact person phone'
            optional :mou_document_number, type: String
            optional :supplier_name, type: String
            # optional :bn_supplier_name, type: String
            optional :supplier_representative, type: String
            # optional :bn_supplier_representative, type: String
            optional :representative_designation, type: String
            # optional :bn_representative_designation, type: String
            optional :representative_contact, type: String
            # optional :bn_representative_contact, type: String
            # optional :supplier_email, type: String
            optional :tin, type: String
            optional :bin, type: String
            optional :contract_start_date, type: Date
            optional :contract_end_date, type: Date
            optional :bank_name, type: String
            # optional :bn_bank_name, type: String
            optional :account_number, type: String
            optional :swift_code, type: String
            # optional :bn_swift_code, type: String
            optional :central_warehouse_address, type: String
            # optional :bn_central_warehouse_address, type: String
            optional :local_warehouse_address, type: String
            # optional :bn_local_warehouse_address, type: String
            requires :address_line, type: String
            optional :pre_payment, type: Boolean
            optional :product_quality_rating, type: Float, description: 'ranging from 1 to 5'
            optional :deliver_time_rating, type: Float, description: 'ranging from 1 to 5'
            optional :service_quality_rating, type: Float
            optional :professionalism_rating, type: Float
            optional :post_payment, type: Boolean
            optional :credit_payment, type: Boolean
            optional :credit_days, type: Integer
            optional :credit_limit, type: BigDecimal
            optional :agami_kam_name, type: String
            # optional :bn_agami_kam_name, type: String
            optional :agami_kam_contact, type: String
            # optional :bn_agami_kam_contact, type: String
            optional :agami_kam_email, type: String
            optional :delivery_responsibility, type: String
            # optional :bn_delivery_responsibility, type: String
            optional :product_lead_time, type: Integer, description: 'in days'
            optional :return_days, type: Integer
            # optional :pickup_locations, type: Array
            # optional :bn_pickup_locations, type: Array
            # requires :address_attributes, type: Hash do
            #   optional :pickup_locations, type: Array
            #   optional :bn_pickup_locations, type: Array
            optional :address_attributes, type: Hash do
              requires :address_line, type: String, description: 'Company address line'
              requires :bn_address_line, type: String, description: 'Company address line in bangla'
              requires :district_id, type: Integer, description: 'Company address district'
              requires :thana_id, type: Integer, description: 'Company address thana'
              requires :area_id, type: Integer, description: 'Company address area'
            end
            # end
          end
        end
        desc 'Create a new supplier.'
        post do
          Supplier.create!(params[:supplier].merge!(created_by_id: @current_staff.id))
          respond_with_json('Successfully created Supplier.', HTTP_CODE[:CREATED])
        rescue StandardError => error
          Rails.logger.info "Unable to create Supplier due to: #{error}"
          error!(respond_with_json('Unable to create Supplier', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Update a supplier'
        route_param :id do
          put do
            supplier = Supplier.find(params[:id])
            supplier if supplier.update!(params[:supplier])
          rescue StandardError => e
            error! respond_with_json("Unable to update Supplier with id #{params[:id]} due to #{e.message}.",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'delete a supplier'
        route_param :id do
          delete do
            unless check_wh_warehouse
              error!(respond_with_json('Not permitted to delete', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end
            supplier = Supplier.find_by(id: params[:id])
            unless supplier.present?
              error!(respond_with_json('Supplier not found', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            if supplier.suppliers_variants.empty?
              supplier.deleted
              respond_with_json('Successfully deleted', HTTP_CODE[:OK]) if rider.destroy!
            else
              error!(respond_with_json('This supplier is associated with products.
                                       Please remove them first.', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end
          rescue StandardError => error
            Rails.logger.info "unable to delete supplier #{error.message}"
            error!(respond_with_json('Unable to delete', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Get a supplier'
        params do
          requires :id, type: Integer, desc: 'supplier id'
        end

        route_param :id do
          get do
            supplier = Supplier.find(params[:id])
            return {} unless supplier

            supplier_json = supplier.as_json
            supplier_json.merge!(supplier_address(supplier.address)) if supplier.address
            supplier_json
          rescue StandardError => error
            error! respond_with_json("Unable to find supplier with id #{params[:id]} due to #{error.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end
        end

        route_param :id do
          resource :suppliers_variants do
            desc "Return a specific Supplier's variants."
            get do
              @suppliers_variants = SuppliersVariant.where(supplier_id: params[:id])
              hash ||= []
              @suppliers_variants.each do |sv|
                variant = sv.variant
                found = hash.detect { |x| x['product'] == variant.product&.title }
                if found.present?
                  found['variants'] << {
                    'id' => variant.id,
                    'name' => variant.sku,
                    'sp_price' => sv.supplier_price,
                    'created_by' => {
                      id: sv.created_by_id,
                      name: Staff.unscoped.find_by(id: sv.created_by_id)&.name,
                    },
                    'product_attribute_values' => product_attribute_values(variant),
                  }
                else
                  hash << {
                    'product' => Product.unscoped.find_by(id: variant.product_id, is_deleted: false)&.title,
                    'variants' => [
                      {
                        'id' => variant.id,
                        'name' => variant.sku,
                        'sp_price' => sv.supplier_price,
                        'created_by' => {
                          id: sv.created_by_id,
                          name: Staff.unscoped.find_by(id: sv.created_by_id)&.name,
                        },
                        'product_attribute_values' => product_attribute_values(variant),
                      },
                    ],
                  }
                end
              rescue StandardError => error
                Rails.logger.info "suppliers variant fetch failed for #{sv.id} #{error.message}"
                next
              end
              hash
            rescue StandardError => error
              Rails.logger.error "\n#{__FILE__}\nUnable to fetch suppliers_variants due to: #{error.message}"
              error!(respond_with_json('Unable to fetch suppliers_variants',
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end

            params do
              requires :suppliers_variants, type: Array do
                requires :variant_id, type: Integer
                requires :supplier_price, type: BigDecimal
              end
            end
            # Bulk Create
            desc 'Bulk create a specific suppliers_variant'
            post do
              supplier = Supplier.find_by!(id: params[:id])
              params[:suppliers_variants].map do |suppliers_variant|
                suppliers_variant.merge!(created_by_id: @current_staff.id)
                supplier.suppliers_variants.create!(suppliers_variant)
              end
            rescue StandardError => error
              error! respond_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end

            # Bulk Update
            desc 'Bulk update a specific suppliers_variant'
            put do
              params[:suppliers_variants].each do |val|
                SuppliersVariant.find_by(supplier_id: params[:id], variant_id: val[:variant_id]).
                  update!(supplier_price: val[:supplier_price])
              rescue StandardError => error
                error! respond_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
            end

            desc 'Delete a variant for a specific supplier.'
            params do
              requires :variant_id, type: Integer
            end
            delete do
              item = SuppliersVariant.find_by!(supplier_id: params[:id], variant_id: params[:variant_id])
              ActiveRecord::Base.transaction do
                item.update(is_deleted: true)
              end
              respond_with_json('Successfully deleted', HTTP_CODE[:OK])

            rescue StandardError => error
              Rails.logger.info "supplier variant deletion failed: #{error.message}"
              error!(respond_with_json('Invalid item requested', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end
        end
      end
    end
  end
end
