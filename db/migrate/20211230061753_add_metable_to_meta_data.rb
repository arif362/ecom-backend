class AddMetableToMetaData < ActiveRecord::Migration[6.0]
  def change
    add_reference :meta_data, :metable, polymorphic: true, index: true
  end
end
