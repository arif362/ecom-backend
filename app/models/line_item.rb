class LineItem < ApplicationRecord
  audited
  has_many :failed_qcs
  belongs_to :itemable, polymorphic: true, optional: true
  belongs_to :variant
  belongs_to :location, optional: true
  has_one :box_line_item

  before_create :assign_qr_code_initial # if self.itemable_type == "WhPurchaseOrder"

  enum reconcilation_status: { closed: 0, pending: 1, settled: 2 }

  attr_accessor :changed_by

  def failed_qcs
    itemable.failed_qcs.where(variant: variant)
  end

  def update_reconcilation_status(changed_by)
    return if failed_qcs.where(is_settled: false).present?

    self.changed_by = changed_by
    settled!
    itemable.update_reconcilation_status(changed_by)
  end

  private

  def assign_qr_code_initial
    self.qr_code_initials = "#{fetch_category_id}-#{fetch_supplier_id}-#{fetch_variant_id}" if self.instance_of? WhPurchaseOrder
  end

  def fetch_category_id
    self.variant.product.categories.first.id.to_s.rjust(3, "0")
  end

  def fetch_variant_id
    self.variant_id.to_s.rjust(5, "0")
  end

  def fetch_supplier_id
    self.itemable.supplier_id.to_s.rjust(4, "0")
  end
end
