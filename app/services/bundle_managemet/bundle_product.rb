module BundleManagement

  class NotFoundError < StandardError
    def initialize(msg = nil)
      super
    end
  end

  class UnacceptableError < StandardError
    def initialize(msg = nil)
      super
    end
  end

  class BundleProduct

    def pack(params)
      current_wh = params[:current_wh]
      bundle_sku_variant = check_bundle_variant(params[:bundle_variant_id])
      bundle_variant_location = check_bundle_variant_location(params[:bundle_location_id], current_wh)
      bundle_quantity = params[:bundle_quantity]

      variant_hash = {}
      ActiveRecord::Base.transaction do
        params[:bundle_variants].each do |bundle_variant|
          quantity = bundle_variant[:packed_quantity]
          variant = check_variant(bundle_variant[:variant_id], bundle_variant[:qr_code], bundle_sku_variant)
          variant_id = variant.id
          bundle_variant_quantity = bundle_sku_variant.bundle&.bundle_variants&.find_by(variant: variant)
          unless bundle_variant_quantity
            fail UnacceptableError, "Variant #{variant.sku} isn't included to this bundle."
          end

          unless variant_hash.keys.include?(variant_id.to_s.to_sym)
            variant_hash = variant_hash.merge({ "#{variant_id}": bundle_variant_quantity.quantity * bundle_quantity })
          end

          variant_hash[:"#{variant_id}"] = variant_hash[:"#{variant_id}"] - quantity
          if variant_hash[:"#{variant_id}"].negative?
            fail UnacceptableError, "You can't take more than #{variant.quantity * bundle_quantity} quantity for sku- #{variant.sku}."
          end

          location = check_variant_location(bundle_variant[:location_id], current_wh)
          warehouse_variant = check_wv(variant, current_wh)
          wv_location = check_wv_location(current_wh, warehouse_variant, variant, location, quantity)
          bundle_variants_stock_update(warehouse_variant, quantity, wv_location, bundle_sku_variant, 'packed')
        end
        fail UnacceptableError, 'Need to pack all quantity in a bundle.' unless variant_hash.values.all?(0)

        warehouse_bundle = bundle_sku_variant.bundle.warehouse_bundles.find_or_create_by(warehouse: current_wh)
        warehouse_bundle.add_line_item(bundle_sku_variant, bundle_quantity, bundle_variant_location.id)
        pack_parent_stock_update(current_wh, bundle_sku_variant, bundle_variant_location, bundle_quantity)
      end
    end

    def unpack(params)
      current_wh = params[:current_wh]
      bundle_sku_variant = check_bundle_variant(params[:bundle_variant_id])
      bundle_location = check_bundle_variant_location(params[:bundle_location_id], current_wh)
      bundle_quantity = params[:bundle_quantity]
      warehouse_variant = check_wv(bundle_sku_variant, current_wh)
      check_wv_location(current_wh, warehouse_variant, bundle_sku_variant, bundle_location, bundle_quantity)

      variant_hash = {}
      unpack_variant_hash = {}
      ActiveRecord::Base.transaction do
        params[:bundle_variants].each do |bundle_variant|
          quantity = bundle_variant[:packed_quantity]
          variant = check_variant(bundle_variant[:variant_id], bundle_variant[:qr_code], bundle_sku_variant)
          variant_id = variant.id
          bundle_variant_quantity = bundle_sku_variant.bundle&.bundle_variants&.find_by(variant: variant)
          if unpack_variant_hash.keys.include?(variant_id.to_s.to_sym)
            unpack_variant_hash[:"#{variant_id}"] = unpack_variant_hash[:"#{variant_id}"] + quantity
          else
            variant_hash = variant_hash.merge({ "#{variant_id}": bundle_variant_quantity.quantity * bundle_quantity})
            unpack_variant_hash = unpack_variant_hash.merge({ "#{variant_id}": quantity })
          end

          location = check_variant_location(bundle_variant[:location_id], current_wh)
          warehouse_variant = check_wv(variant, current_wh)
          wv_location = warehouse_variant.warehouse_variants_locations.find_or_create_by!(location: location)
          bundle_variants_stock_update(warehouse_variant, quantity, wv_location, bundle_sku_variant, 'unpacked')
        end

        array = []
        unpack_variant_hash.each do |key, value|
          array << variant_hash[key] - unpack_variant_hash[key]
        end
        fail UnacceptableError, 'Need to unpack all quantity from a bundle.' unless array.all?(0)

        unpack_parent_stock_update(current_wh, bundle_sku_variant, bundle_location, bundle_quantity)
      end
    end

    def check_bundle_variant(bundle_variant_id)
      bundle_sku_variant = Variant.find_by(id: bundle_variant_id)
      fail NotFoundError, 'Bundle Variant not found' unless bundle_sku_variant

      bundle_sku_variant
    end

    def check_bundle_variant_location(bundle_location_id, current_wh)
      bundle_location = current_wh.locations.find_by(id: bundle_location_id)
      fail NotFoundError, 'Location not found in this FC for bundle' unless bundle_location

      bundle_location
    end

    def check_variant(variant_id, qr_code, bundle_sku_variant)
      variant = Variant.find_by(id: variant_id)
      fail NotFoundError, "Variant ID- #{variant_id} is not found" unless variant

      item_code = variant.line_items.find_by(qr_code: qr_code)
      fail NotFoundError, "Qr code #{qr_code} not found for sku- #{variant.sku}" unless item_code.present?

      unless variant.bundles.find_by(variant: bundle_sku_variant).present?
        fail NotFoundError, "SKU - #{variant.sku} is not allowed to pack under this bundle"
      end

      variant
    end

    def check_variant_location(location_id, warehouse)
      location = warehouse.locations.find_by(id: location_id)
      fail NotFoundError, "Location - #{location_id} not found in #{warehouse.name}" unless location

      location
    end

    def check_wv(variant, warehouse)
      warehouse_variant = warehouse.warehouse_variants.find_by(variant: variant)
      fail NotFoundError, "SKU- #{variant.sku} not found in #{warehouse.name}" unless warehouse_variant

      warehouse_variant
    end

    def check_wv_location(current_wh, warehouse_variant, variant, location, quantity)
      wv_location = warehouse_variant.warehouse_variants_locations.find_by(location: location)
      unless wv_location
        fail NotFoundError, "Location - #{location.code} not found for sku - #{variant.sku} in #{current_wh.name} FC"
      end

      unless warehouse_variant.available_quantity >= quantity && wv_location.quantity >= quantity
        fail UnacceptableError, "Available quantity of sku - #{variant.sku} not enough in #{current_wh.name} FC"
      end

      wv_location
    end

    def bundle_variants_stock_update(warehouse_variant, quantity, wv_location, bundle_sku_variant, bundle_action)
      warehouse_variant.update!(
        available_quantity: available_quantity(bundle_action, quantity, warehouse_variant),
      )
      wv_location.update!(quantity: wv_location_qty(bundle_action, quantity, wv_location))
      bundle_stock_change(bundle_action, warehouse_variant, quantity, bundle_sku_variant)
    end

    def pack_parent_stock_update(warehouse, bundle_sku_variant, bundle_location, bundle_quantity)
      bundle_warehouse_variant = warehouse.warehouse_variants.find_or_create_by!(variant: bundle_sku_variant)
      bundle_warehouse_variant.update!(available_quantity: bundle_warehouse_variant.available_quantity + bundle_quantity)

      warehouse_bundle_variant_location = bundle_warehouse_variant.warehouse_variants_locations.find_or_create_by!(
        location: bundle_location,
      )

      bundle_sku_variant.bundle.update!(is_editable: false)
      warehouse_bundle_variant_location.update!(quantity: warehouse_bundle_variant_location.quantity + bundle_quantity)
      bundle_warehouse_variant.save_stock_change('bundle_pack', bundle_quantity, bundle_sku_variant, nil,
                                                 'available_quantity_change')
    end

    def unpack_parent_stock_update(warehouse, bundle_sku_variant, bundle_location, bundle_quantity)
      warehouse_bundle_variant = warehouse.warehouse_variants.find_by(variant: bundle_sku_variant)
      fail NotFoundError, "#{bundle_sku_variant.sku} not found" unless warehouse_bundle_variant

      warehouse_bundle_variant.update!(available_quantity: warehouse_bundle_variant.available_quantity - bundle_quantity)
      warehouse_bundle_variant_location = warehouse_bundle_variant.warehouse_variants_locations.find_by(
        location: bundle_location,
      )
      unless warehouse_bundle_variant_location
        fail NotFoundError, "Location #{bundle_location.code} not found"
      end

      warehouse_bundle_variant_location.update!(quantity: warehouse_bundle_variant_location.quantity - bundle_quantity)
      warehouse_bundle_variant.save_stock_change('bundle_unpack', bundle_quantity, bundle_sku_variant,
                                                 'available_quantity_change', nil)
    end

    def available_quantity(bundle_action, quantity, warehouse_variant)
      case bundle_action
      when 'packed'
        warehouse_variant.available_quantity - quantity
      when 'unpacked'
        warehouse_variant.available_quantity + quantity
      else
        warehouse_variant.available_quantity
      end
    end

    def wv_location_qty(bundle_action, quantity, wv_location)
      case bundle_action
      when 'packed'
        wv_location.quantity - quantity
      when 'unpacked'
        wv_location.quantity + quantity
      else
        wv_location.quantity
      end
    end

    def bundle_stock_change(bundle_action, warehouse_variant, quantity, bundle_sku_variant)
      case bundle_action
      when 'packed'
        pack_stock_change(warehouse_variant, quantity, bundle_sku_variant)
      when 'unpacked'
        unpack_stock_change(warehouse_variant, quantity, bundle_sku_variant)
      else
        ''
      end
    end

    def pack_stock_change(warehouse_variant, quantity, bundle_sku_variant)
      warehouse_variant.save_stock_change('bundle_pack', quantity,
                                          bundle_sku_variant, 'available_quantity_change',
                                          nil)
    end

    def unpack_stock_change(warehouse_variant, quantity, bundle_sku_variant)
      warehouse_variant.save_stock_change('bundle_unpack', quantity,
                                          bundle_sku_variant, nil,
                                          'available_quantity_change')
    end

    private

    def load_warehouse
      @current_staff.warehouse
    end
  end
end
