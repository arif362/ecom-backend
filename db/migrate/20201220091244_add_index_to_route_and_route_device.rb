class AddIndexToRouteAndRouteDevice < ActiveRecord::Migration[6.0]
  def change
    add_index :routes, :title
    add_index :route_devices, :device_id
  end
end
