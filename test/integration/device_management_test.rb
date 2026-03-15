require "test_helper"

# End-to-end HTTP flows covering full user journeys across multiple requests.
class DeviceManagementTest < ActionDispatch::IntegrationTest
  # ---------------------------------------------------------------------------
  # Full CRUD lifecycle
  # ---------------------------------------------------------------------------

  test "create, view, edit, and delete a device" do
    # Create
    post devices_path, params: { device: { type: "Server", name: "Integration Server", status: "active", location: "Rack 3" } }
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_includes response.body, "Integration Server"
    assert_includes response.body, "Rack 3"

    device_id = Device.find_by(name: "Integration Server").id

    # Edit
    patch device_path(device_id), params: { device: { name: "Integration Server (updated)", status: "maintenance" } }
    assert_response :redirect
    follow_redirect!
    assert_includes response.body, "Integration Server (updated)"
    assert_includes response.body, "Maintenance"

    # Appears on index
    get devices_path
    assert_includes response.body, "Integration Server (updated)"

    # Delete
    delete device_path(device_id)
    assert_response :redirect
    follow_redirect!
    assert_not_includes response.body, "Integration Server (updated)"
  end

  test "create invalid device, fix errors, and save" do
    # Submit invalid (missing name)
    post devices_path, params: { device: { type: "Router", name: "" } }
    assert_response :unprocessable_entity
    assert_includes response.body, "can&#39;t be blank"

    # Submit valid
    assert_difference "Device.count", 1 do
      post devices_path, params: { device: { type: "Router", name: "Fixed Router", status: "active" } }
    end
    assert_response :redirect
  end

  # ---------------------------------------------------------------------------
  # Type filtering flow
  # ---------------------------------------------------------------------------

  test "filter by type and navigate back to all" do
    get devices_path(type: "Camera")
    assert_response :success
    assert_includes response.body, devices(:camera_entrance).name
    assert_not_includes response.body, devices(:core_switch).name

    get devices_path
    assert_includes response.body, devices(:camera_entrance).name
    assert_includes response.body, devices(:core_switch).name
  end

  test "each device type filter shows correct devices" do
    Device::TYPES.each do |type|
      get devices_path(type: type)
      assert_response :success

      Device.where(type: type).each do |device|
        assert_includes response.body, device.name, "Expected #{device.name} to appear when filtering by #{type}"
      end

      Device.where.not(type: type).each do |device|
        assert_not_includes response.body, device.name, "Expected #{device.name} NOT to appear when filtering by #{type}"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Root path
  # ---------------------------------------------------------------------------

  test "root path renders device index" do
    get root_path
    assert_response :success
    assert_includes response.body, devices(:camera_entrance).name
  end

  # ---------------------------------------------------------------------------
  # Notice flash propagation
  # ---------------------------------------------------------------------------

  test "create success notice is shown on show page" do
    post devices_path, params: { device: { type: "Camera", name: "Flash Camera", status: "active" } }
    follow_redirect!
    assert_includes response.body, "Device was successfully created."
  end

  test "update success notice is shown on show page" do
    patch device_path(devices(:camera_entrance)), params: { device: { name: "Flash Update" } }
    follow_redirect!
    assert_includes response.body, "Device was successfully updated."
  end

  test "delete success notice is shown on index page" do
    delete device_path(devices(:camera_entrance))
    follow_redirect!
    assert_includes response.body, "Device was successfully deleted."
  end

  # ---------------------------------------------------------------------------
  # Status transitions
  # ---------------------------------------------------------------------------

  test "transition device from active to inactive" do
    assert_equal "active", devices(:camera_entrance).status
    patch device_path(devices(:camera_entrance)), params: { device: { status: "inactive" } }
    assert_equal "inactive", devices(:camera_entrance).reload.status
  end

  test "transition device from active to maintenance" do
    patch device_path(devices(:camera_entrance)), params: { device: { status: "maintenance" } }
    assert_equal "maintenance", devices(:camera_entrance).reload.status
  end

  test "transition device from maintenance back to active" do
    patch device_path(devices(:file_server)), params: { device: { status: "active" } }
    assert_equal "active", devices(:file_server).reload.status
  end

  # ---------------------------------------------------------------------------
  # Multiple devices in sequence
  # ---------------------------------------------------------------------------

  test "create multiple devices of different types" do
    initial_count = Device.count

    post devices_path, params: { device: { type: "Camera", name: "Cam A", status: "active" } }
    post devices_path, params: { device: { type: "Switch", name: "Switch A", status: "active" } }
    post devices_path, params: { device: { type: "Server", name: "Server A", status: "active" } }

    assert_equal initial_count + 3, Device.count
    assert_equal 1, Device.where(name: "Cam A").count
    assert_equal 1, Device.where(name: "Switch A").count
    assert_equal 1, Device.where(name: "Server A").count
  end

  test "delete one device does not affect others" do
    names_before = Device.pluck(:name) - [devices(:camera_entrance).name]
    delete device_path(devices(:camera_entrance))
    names_after = Device.pluck(:name)
    assert_equal names_before.sort, names_after.sort
  end
end
