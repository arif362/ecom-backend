module ShopothWarehouse
  module V1
    class FlashSales < ShopothWarehouse::Base

      # rubocop:disable Metrics/BlockLength
      resource :flash_sales do

        # GET /flash_sales/
        desc 'Get the flash sale list'
        params do
          use :pagination, per_page: 50
        end
        get do
          flash_sales = Promotion.flash_sale.includes(promotion_variants: :variant).order(created_at: :desc)
          flash_sales = ShopothWarehouse::V1::Entities::FlashSale.represent(flash_sales)
          # TODO: Need to Optimize Query
          success_response_with_json('Successfully fetched flash sale list', HTTP_CODE[:OK], paginate(Kaminari.paginate_array(flash_sales)))
        rescue StandardError => error
          error!(respond_with_json("Unable to fetch flash sale list due to #{error.message}",
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        # GET /flash_sales/:id
        desc 'Get a Specific Flash sale.'
        route_param :id do
          get do
            flash_sale = Promotion.flash_sale.find(params[:id])
            flash_sale = ShopothWarehouse::V1::Entities::FlashSale.represent(flash_sale)
            success_response_with_json('Successfully fetched flash sale details', HTTP_CODE[:OK], flash_sale)
          rescue StandardError
            error!(respond_with_json('Unable to Find flash sale',
                                     HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end
        end

        # GET /flash_sales/:id/export_variants
        route_param :id do
          get 'export_variants' do
            flash_sale = Promotion.flash_sale.find(params[:id])
            p_variants = []
            flash_sale.promotion_variants.each do |p_variant|
              p_variants << { variant_id: p_variant.variant_id, consumer_discount: p_variant.promotional_discount}
            end
            p_variants
          rescue StandardError
            error!(respond_with_json('Unable to export flash sale variants',
                                     HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end
        end

        # POST /flash_sales/
        desc 'Create a new flash sale.'
        params do
          requires :flash_sale, type: Hash do
            requires :title, type: String
            requires :title_bn, type: String
            optional :warehouse_id, type: Integer
            requires :from_date, type: Date
            requires :to_date, type: Date
            optional :is_active, type: Boolean
            optional :start_time, type: String
            optional :end_time, type: String
            requires :file, type: File
          end
        end

        post do
          valid_file_type = %w(.csv application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.ms-excel text/comma-separated-values text/csv application/csv)
          params[:flash_sale][:from_date] = params[:flash_sale][:from_date].to_datetime.utc
          params[:flash_sale][:to_date] = params[:flash_sale][:to_date].to_datetime.utc
          params[:flash_sale][:promotion_category] = :flash_sale
          flash_sale = Promotion.new(params[:flash_sale].except(:file).merge!(created_by_id: @current_staff.id))

          file = params[:flash_sale][:file]
          file_path = File.expand_path(file['tempfile'])
          unless valid_file_type.include?(file['type'])
            error!(failure_response_with_json('Please provide CSV or XLSX file.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          csv_file = CSV.read(file_path, headers: true, col_sep: ',', header_converters: :symbol)
          csv_file.each do |row|
            data = row.to_h

            variant_id = data[:variant_id].to_i
            variant = Variant.find_by(id: variant_id)
            next unless variant

            consumer_discount = data[:consumer_discount].to_i
            consumer_price = variant.price_consumer - consumer_discount
            flash_sale.promotion_variants.build(promotional_price: consumer_price,
                                                promotional_discount: consumer_discount,
                                                product_id: variant.product_id, variant_id: variant_id)
          end
          flash_sale.save!
          flash_sale = ShopothWarehouse::V1::Entities::FlashSale.represent(flash_sale)
          success_response_with_json('Successfully created flash sale', HTTP_CODE[:OK], flash_sale)
        rescue StandardError => error
          Rails.logger.info "Flash sale creation failed #{error.message}"
          error!(respond_with_json('Unable to create flash sale. Variants not found',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # PUT /flash_sales/:id
        desc 'Update a flash sale'
        params do
          requires :flash_sale, type: Hash do
            requires :title, type: String
            requires :title_bn, type: String
            optional :warehouse_id, type: Integer
            requires :from_date, type: Date
            requires :to_date, type: Date
            optional :is_active, type: Boolean
            optional :start_time, type: String
            optional :end_time, type: String
          end
        end

        route_param :id do
          put do
            params[:flash_sale][:from_date] = params[:flash_sale][:from_date].to_datetime.utc
            params[:flash_sale][:to_date] = params[:flash_sale][:to_date].to_datetime.utc
            flash_sale = Promotion.flash_sale.find(params[:id])
            flash_sale.update!(params[:flash_sale])
            flash_sale = ShopothWarehouse::V1::Entities::FlashSale.represent(flash_sale)
            success_response_with_json('Successfully updated flash sale', HTTP_CODE[:OK], flash_sale)
          rescue StandardError => error
            error!(respond_with_json("Unable to update flash sale. error: #{error}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        # DELETE /flash_sales/:id/
        desc 'Delete a flash sale'
        route_param :id do
          delete do
            Promotion.flash_sale.find(params[:id]).update!(is_active: false)
            respond_with_json("Flash sale is successfully made inactive with id #{params[:id]}",
                              HTTP_CODE[:OK])
          rescue StandardError => error
            error! respond_with_json("Unable to delete/make inactive Flash sale. error: #{error}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
