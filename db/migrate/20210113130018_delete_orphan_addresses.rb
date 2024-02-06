class DeleteOrphanAddresses < ActiveRecord::Migration[6.0]
  def up
    Address.where.not(addressable_id: Warehouse.ids).where(addressable_type: 'Warehouse').destroy_all
  end

  def down; end
end
