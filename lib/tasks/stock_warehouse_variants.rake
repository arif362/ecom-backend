namespace :stock_warehouse_variants do
  task update: :environment do |t, args|
    wv = {}
    StockChange.order(created_at: :asc).each do |st|
      if wv[st.warehouse_variant_id].present?
        wv[st.warehouse_variant_id] = {
          available_quantity: wv[st.warehouse_variant_id][:available_quantity] + st[:available_quantity_change],
          booked_quantity: wv[st.warehouse_variant_id][:booked_quantity] + st[:booked_quantity_change],
          packed_quantity: wv[st.warehouse_variant_id][:packed_quantity] + st[:packed_quantity_change],
          in_transit_quantity: wv[st.warehouse_variant_id][:in_transit_quantity] + st[:in_transit_quantity_change],
          in_partner_quantity: wv[st.warehouse_variant_id][:in_partner_quantity] + st[:in_partner_quantity_change],
          blocked_quantity: wv[st.warehouse_variant_id][:blocked_quantity] + st[:blocked_quantity_change],
          garbage_quantity: wv[st.warehouse_variant_id][:garbage_quantity] + st[:garbage_quantity_change],
        }
        st.update_columns(available_quantity: wv[st.warehouse_variant_id][:available_quantity],
                          booked_quantity: wv[st.warehouse_variant_id][:booked_quantity],
                          packed_quantity: wv[st.warehouse_variant_id][:packed_quantity],
                          in_transit_quantity: wv[st.warehouse_variant_id][:in_transit_quantity],
                          in_partner_quantity: wv[st.warehouse_variant_id][:in_partner_quantity],
                          blocked_quantity: wv[st.warehouse_variant_id][:blocked_quantity],
                          garbage_quantity: wv[st.warehouse_variant_id][:garbage_quantity])
      else
        wv[st.warehouse_variant_id] = { available_quantity: st.available_quantity,
                                        booked_quantity: st.booked_quantity,
                                        packed_quantity: st.packed_quantity,
                                        in_transit_quantity: st.in_transit_quantity,
                                        in_partner_quantity: st.in_partner_quantity,
                                        blocked_quantity: st.blocked_quantity,
                                        garbage_quantity: st.garbage_quantity, }
        p "<<<<<<<<<<<<<<<<<<<<create - #{wv[st.warehouse_variant_id]}  >>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      end
    end
  end
end
