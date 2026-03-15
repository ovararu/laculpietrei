class AddParentDeviceToDevices < ActiveRecord::Migration[8.1]
  def change
    add_column :devices, :parent_device_id, :integer
    add_index :devices, :parent_device_id
  end
end
