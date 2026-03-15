class AddCredentialsToDevices < ActiveRecord::Migration[8.1]
  def change
    add_column :devices, :username, :string
    add_column :devices, :password, :string
  end
end
