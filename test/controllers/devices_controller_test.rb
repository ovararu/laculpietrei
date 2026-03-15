require "test_helper"

class DevicesControllerTest < ActionDispatch::IntegrationTest
  # ---------------------------------------------------------------------------
  # GET /devices.xlsx (export)
  # ---------------------------------------------------------------------------

  test "xlsx export returns 200 with correct content type" do
    get devices_path(format: :xlsx)
    assert_response :success
    assert_includes response.content_type, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  test "xlsx export sets attachment content-disposition with default filename" do
    get devices_path(format: :xlsx)
    assert_includes response.headers["Content-Disposition"], "devices.xlsx"
  end

  test "xlsx export with type filter uses typed filename" do
    get devices_path(format: :xlsx, type: "Camera")
    assert_includes response.headers["Content-Disposition"], "devices_camera.xlsx"
  end

  test "xlsx export response body is non-empty" do
    get devices_path(format: :xlsx)
    assert response.body.length > 0
  end

  test "xlsx export with type filter still returns 200" do
    Device::TYPES.each do |type|
      get devices_path(format: :xlsx, type: type)
      assert_response :success, "Expected xlsx export for type #{type} to succeed"
    end
  end

  # ---------------------------------------------------------------------------
  # GET /devices (index)
  # ---------------------------------------------------------------------------

  test "index returns 200" do
    get devices_path
    assert_response :success
  end

  test "index shows all devices" do
    get devices_path
    assert_includes response.body, devices(:camera_entrance).name
    assert_includes response.body, devices(:core_switch).name
    assert_includes response.body, devices(:main_router).name
    assert_includes response.body, devices(:reception_pc).name
    assert_includes response.body, devices(:file_server).name
  end

  test "index filtered by Camera shows only cameras" do
    get devices_path(type: "Camera")
    assert_response :success
    assert_includes response.body, devices(:camera_entrance).name
    assert_includes response.body, devices(:camera_parking).name
    assert_not_includes response.body, devices(:core_switch).name
    assert_not_includes response.body, devices(:reception_pc).name
  end

  test "index filtered by Switch shows only switches" do
    get devices_path(type: "Switch")
    assert_includes response.body, devices(:core_switch).name
    assert_not_includes response.body, devices(:camera_entrance).name
  end

  test "index filtered by Router shows only routers" do
    get devices_path(type: "Router")
    assert_includes response.body, devices(:main_router).name
    assert_not_includes response.body, devices(:camera_entrance).name
  end

  test "index filtered by Pc shows only PCs" do
    get devices_path(type: "Pc")
    assert_includes response.body, devices(:reception_pc).name
    assert_not_includes response.body, devices(:camera_entrance).name
  end

  test "index filtered by Server shows only servers" do
    get devices_path(type: "Server")
    assert_includes response.body, devices(:file_server).name
    assert_not_includes response.body, devices(:camera_entrance).name
  end

  test "index with invalid type param returns all devices" do
    get devices_path(type: "Drone")
    assert_response :success
    assert_includes response.body, devices(:camera_entrance).name
    assert_includes response.body, devices(:core_switch).name
  end

  test "index with empty type param returns all devices" do
    get devices_path(type: "")
    assert_response :success
    assert_includes response.body, devices(:camera_entrance).name
  end

  test "index shows status badges" do
    get devices_path
    assert_includes response.body, "Active"
    assert_includes response.body, "Inactive"
    assert_includes response.body, "Maintenance"
  end

  test "index sets @current_type when type param present" do
    get devices_path(type: "Camera")
    assert_equal "Camera", controller.instance_variable_get(:@current_type)
  end

  test "index @current_type is nil without type param" do
    get devices_path
    assert_nil controller.instance_variable_get(:@current_type)
  end

  # ---------------------------------------------------------------------------
  # GET /devices/:id (show)
  # ---------------------------------------------------------------------------

  test "show returns 200" do
    get device_path(devices(:camera_entrance))
    assert_response :success
  end

  test "show displays device name" do
    get device_path(devices(:camera_entrance))
    assert_includes response.body, "Camera - Entrance"
  end

  test "show displays device attributes" do
    get device_path(devices(:camera_entrance))
    assert_includes response.body, "Hikvision"
    assert_includes response.body, "192.168.1.101"
    assert_includes response.body, "Main Entrance"
  end

  test "show displays type label" do
    get device_path(devices(:reception_pc))
    assert_includes response.body, "PC"
  end

  test "show displays notes when present" do
    get device_path(devices(:file_server))
    assert_includes response.body, "Scheduled for upgrade"
  end

  test "show returns 404 for nonexistent device" do
    get device_path(id: 0)
    assert_response :not_found
  end

  # ---------------------------------------------------------------------------
  # GET /devices/new (new)
  # ---------------------------------------------------------------------------

  test "new returns 200" do
    get new_device_path
    assert_response :success
  end

  test "new renders a form" do
    get new_device_path
    assert_select "form"
  end

  test "new with valid type param pre-builds that type" do
    get new_device_path(type: "Camera")
    assert_response :success
    device = controller.instance_variable_get(:@device)
    assert_instance_of Camera, device
  end

  test "new with invalid type param builds base Device" do
    get new_device_path(type: "Drone")
    assert_response :success
    device = controller.instance_variable_get(:@device)
    assert_instance_of Device, device
  end

  test "new without type param builds base Device" do
    get new_device_path
    device = controller.instance_variable_get(:@device)
    assert_instance_of Device, device
  end

  # ---------------------------------------------------------------------------
  # POST /devices (create)
  # ---------------------------------------------------------------------------

  test "create with valid params saves device" do
    assert_difference "Device.count", 1 do
      post devices_path, params: { device: { type: "Camera", name: "New Camera", status: "active" } }
    end
  end

  test "create with valid params redirects to show" do
    post devices_path, params: { device: { type: "Camera", name: "New Camera", status: "active" } }
    assert_redirected_to device_path(Device.last)
  end

  test "create sets flash notice on success" do
    post devices_path, params: { device: { type: "Camera", name: "New Camera", status: "active" } }
    assert_equal "Device was successfully created.", flash[:notice]
  end

  test "create assigns correct STI class" do
    post devices_path, params: { device: { type: "Switch", name: "New Switch", status: "active" } }
    assert_instance_of Switch, Device.last
  end

  Device::TYPES.each do |type|
    test "create stores type #{type} correctly" do
      post devices_path, params: { device: { type: type, name: "A #{type}", status: "active" } }
      assert_equal type, Device.last.type
    end
  end

  test "create persists optional attributes" do
    post devices_path, params: { device: {
      type: "Server",
      name: "New Server",
      brand: "HP",
      model_number: "DL380",
      serial_number: "XYZ",
      ip_address: "10.0.0.5",
      mac_address: "FF:EE:DD:CC:BB:AA",
      location: "Rack 2",
      status: "active",
      notes: "Primary server",
      purchased_at: "2024-01-01",
      warranty_expires_at: "2027-01-01"
    } }
    device = Device.last
    assert_equal "HP", device.brand
    assert_equal "DL380", device.model_number
    assert_equal "XYZ", device.serial_number
    assert_equal "10.0.0.5", device.ip_address
    assert_equal "FF:EE:DD:CC:BB:AA", device.mac_address
    assert_equal "Rack 2", device.location
    assert_equal "Primary server", device.notes
  end

  test "create with missing name re-renders new" do
    assert_no_difference "Device.count" do
      post devices_path, params: { device: { type: "Camera", name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "create with invalid status re-renders new" do
    assert_no_difference "Device.count" do
      post devices_path, params: { device: { type: "Camera", name: "Test", status: "broken" } }
    end
    assert_response :unprocessable_entity
  end

  # ---------------------------------------------------------------------------
  # GET /devices/:id/edit (edit)
  # ---------------------------------------------------------------------------

  test "edit returns 200" do
    get edit_device_path(devices(:camera_entrance))
    assert_response :success
  end

  test "edit renders a form" do
    get edit_device_path(devices(:camera_entrance))
    assert_select "form"
  end

  test "edit pre-fills device name" do
    get edit_device_path(devices(:camera_entrance))
    assert_includes response.body, "Camera - Entrance"
  end

  # ---------------------------------------------------------------------------
  # PATCH /devices/:id (update)
  # ---------------------------------------------------------------------------

  test "update with valid params redirects to show" do
    patch device_path(devices(:camera_entrance)), params: { device: { name: "Updated Camera" } }
    assert_redirected_to device_path(devices(:camera_entrance))
  end

  test "update changes device name" do
    patch device_path(devices(:camera_entrance)), params: { device: { name: "Renamed Camera" } }
    assert_equal "Renamed Camera", devices(:camera_entrance).reload.name
  end

  test "update changes device status" do
    patch device_path(devices(:camera_entrance)), params: { device: { status: "maintenance" } }
    assert_equal "maintenance", devices(:camera_entrance).reload.status
  end

  test "update sets flash notice on success" do
    patch device_path(devices(:camera_entrance)), params: { device: { name: "Updated" } }
    assert_equal "Device was successfully updated.", flash[:notice]
  end

  test "update can change device type" do
    id = devices(:camera_entrance).id
    patch device_path(devices(:camera_entrance)), params: { device: { type: "Server", name: "Test" } }
    assert_equal "Server", Device.find(id).type
  end

  test "update with blank name re-renders edit" do
    patch device_path(devices(:camera_entrance)), params: { device: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "update with invalid status re-renders edit" do
    patch device_path(devices(:camera_entrance)), params: { device: { status: "unknown" } }
    assert_response :unprocessable_entity
  end

  test "update does not change other devices" do
    other = devices(:core_switch)
    patch device_path(devices(:camera_entrance)), params: { device: { name: "Changed" } }
    assert_equal "Core Switch", other.reload.name
  end

  # ---------------------------------------------------------------------------
  # DELETE /devices/:id (destroy)
  # ---------------------------------------------------------------------------

  test "destroy removes the device" do
    device = devices(:camera_entrance)
    assert_difference "Device.count", -1 do
      delete device_path(device)
    end
  end

  test "destroy redirects to index" do
    delete device_path(devices(:camera_entrance))
    assert_redirected_to devices_path
  end

  test "destroy sets flash notice" do
    delete device_path(devices(:camera_entrance))
    assert_equal "Device was successfully deleted.", flash[:notice]
  end

  test "destroyed device is no longer findable" do
    device_id = devices(:camera_entrance).id
    delete device_path(devices(:camera_entrance))
    assert_raises(ActiveRecord::RecordNotFound) { Device.find(device_id) }
  end
end
