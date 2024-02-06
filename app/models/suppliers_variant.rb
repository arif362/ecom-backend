class SuppliersVariant < ApplicationRecord
  audited
  belongs_to :variant
  belongs_to :supplier
  belongs_to :staff, optional: true
  validate :check_unique

  default_scope { where(is_deleted: false) }

  def check_unique
    if SuppliersVariant.where.not(id: id).find_by(variant_id: variant_id, is_deleted: false, supplier_id: supplier_id).present?
      errors.add(:base, 'variant has already been assigned to this supplier')
    end
  end

end
