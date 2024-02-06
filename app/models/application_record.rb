class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  PO_TYPE = {
   wh: 'WhPurchaseOrder',
   dh: 'DhPurchaseOrder',
   rto: 'ReturnTransferOrder'
  }.freeze

  def deleted
    self.update(is_deleted: true)
  end
end
