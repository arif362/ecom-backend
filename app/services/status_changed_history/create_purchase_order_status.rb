module StatusChangedHistory
  class CreatePurchaseOrderStatus
    include Interactor

    delegate :order,
             :order_status,
             :changed_by,
             :purchase_order_status,
             to: :context

    def call
      context.purchase_order_status = PurchaseOrderStatus.new purchase_order_status_attributes
      context.fail!(error: purchase_order_status.errors.full_messages.to_sentence) unless purchase_order_status.save!
    end

    private

    def purchase_order_status_attributes
      {
        orderable: order,
        status: order_status,
        changed_by_id: changed_by&.id,
        changed_by_type: changed_by&.class&.name,
      }
    end
  end
end
