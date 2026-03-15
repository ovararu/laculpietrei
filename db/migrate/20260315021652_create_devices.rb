class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices do |t|
      t.string :type, null: false
      t.string :name, null: false
      t.string :brand
      t.string :model_number
      t.string :serial_number
      t.string :ip_address
      t.string :mac_address
      t.string :location
      t.string :status, default: "active"
      t.text :notes
      t.date :purchased_at
      t.date :warranty_expires_at

      t.timestamps
    end

    add_index :devices, :type
    add_index :devices, :status
  end
end
