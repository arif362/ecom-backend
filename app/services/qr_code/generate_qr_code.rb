module QrCode
  class GenerateQrCode
    include Interactor

    delegate :line_item,
             :variant,
             :last_item_index,
             :quantity_start,
             :quantity_end,
             :updated_line_item,
             to: :context

    def call
      context.variant = line_item.variant
      context.last_item_index = variant.last_item_index.to_i
      context.quantity_start = last_item_index + 1
      context.quantity_end = last_item_index + line_item.quantity.to_i
      context.updated_line_item = update_line_item
      update_variant
    end

    def update_line_item
      if line_item.qr_code_variant_quantity_start.nil? && line_item.qr_code_variant_quantity_end.nil?
        updated_line_item = line_item.update(
          qr_code_variant_quantity_start: context.quantity_start,
          qr_code_variant_quantity_end: context.quantity_end,
          )
        line_item if updated_line_item
      else
        line_item
      end
    end

    def update_variant
      context.variant.update(
        last_item_index: context.quantity_end
      )
    end
  end
end
