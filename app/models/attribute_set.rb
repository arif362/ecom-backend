class AttributeSet < ApplicationRecord
  audited
  has_many :products, dependent: :restrict_with_exception
  has_many :attribute_set_product_attributes, dependent: :restrict_with_exception
  has_many :product_attributes, through: :attribute_set_product_attributes

  validates_uniqueness_of :title, :unique_id
  before_create :assign_unique_id
  before_destroy :call_3ps_delete_api

  def created_by
    {
      id: created_by_id,
      name: Staff.unscoped.find_by(id: created_by_id)&.name,
    }
  end

  def assign_unique_id
    self.unique_id = SecureRandom.uuid
  end

  def call_3ps_delete_api
    response = Thanos::AttributeSet.delete(self,
                                product_attributes.map(&:unique_id).split(',').join(','))
    return unless response[:error].present?

    e = errors.add(:base, (response[:error_descrip]).to_s)
    fail StandardError, e.to_s
  end
end
