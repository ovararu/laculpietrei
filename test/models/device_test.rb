require "test_helper"

class DeviceTest < ActiveSupport::TestCase
  # ---------------------------------------------------------------------------
  # Validations — name
  # ---------------------------------------------------------------------------

  test "valid camera with only name" do
    assert Camera.new(name: "Test Camera").valid?
  end

  test "invalid without name" do
    device = Camera.new
    assert_not device.valid?
    assert_includes device.errors[:name], "can't be blank"
  end

  test "invalid with blank name" do
    device = Camera.new(name: "   ")
    assert_not device.valid?
    assert_includes device.errors[:name], "can't be blank"
  end

  # ---------------------------------------------------------------------------
  # Validations — type
  # ---------------------------------------------------------------------------

  test "invalid with unknown type string" do
    device = Camera.new(name: "Test")
    device.write_attribute(:type, "Drone")
    assert_not device.valid?
    assert_includes device.errors[:type], "is not included in the list"
  end

  test "invalid with nil type" do
    device = Device.new(name: "Test")
    assert_not device.valid?
    assert device.errors[:type].any?
  end

  Device::TYPES.each do |type|
    test "valid with type #{type}" do
      device = type.constantize.new(name: "A #{type}")
      assert device.valid?, "Expected #{type} to be valid, errors: #{device.errors.full_messages}"
    end
  end

  # ---------------------------------------------------------------------------
  # Validations — status
  # ---------------------------------------------------------------------------

  test "invalid with unknown status" do
    device = Camera.new(name: "Test", status: "broken")
    assert_not device.valid?
    assert_includes device.errors[:status], "is not included in the list"
  end

  test "invalid with blank status" do
    device = Camera.new(name: "Test", status: "")
    assert_not device.valid?
  end

  Device::STATUSES.each do |status|
    test "valid with status #{status}" do
      device = Camera.new(name: "Test", status: status)
      assert device.valid?, "Expected status '#{status}' to be valid"
    end
  end

  # ---------------------------------------------------------------------------
  # Default values
  # ---------------------------------------------------------------------------

  test "default status is active after save" do
    device = Camera.create!(name: "Test")
    assert_equal "active", device.status
  end

  test "default status is active on new record" do
    device = Camera.new(name: "Test")
    device.valid?
    # status default comes from DB default; new record doesn't load DB defaults
    # but after save it should be active
    device.save!
    assert_equal "active", device.reload.status
  end

  # ---------------------------------------------------------------------------
  # type_label
  # ---------------------------------------------------------------------------

  test "type_label returns Camera for Camera" do
    assert_equal "Camera", devices(:camera_entrance).type_label
  end

  test "type_label returns Switch for Switch" do
    assert_equal "Switch", devices(:core_switch).type_label
  end

  test "type_label returns Router for Router" do
    assert_equal "Router", devices(:main_router).type_label
  end

  test "type_label returns PC for Pc" do
    assert_equal "PC", devices(:reception_pc).type_label
  end

  test "type_label returns Server for Server" do
    assert_equal "Server", devices(:file_server).type_label
  end

  # ---------------------------------------------------------------------------
  # STI — class identity
  # ---------------------------------------------------------------------------

  test "fixture camera_entrance is a Camera instance" do
    assert_instance_of Camera, devices(:camera_entrance)
  end

  test "fixture core_switch is a Switch instance" do
    assert_instance_of Switch, devices(:core_switch)
  end

  test "fixture main_router is a Router instance" do
    assert_instance_of Router, devices(:main_router)
  end

  test "fixture reception_pc is a Pc instance" do
    assert_instance_of Pc, devices(:reception_pc)
  end

  test "fixture file_server is a Server instance" do
    assert_instance_of Server, devices(:file_server)
  end

  test "all STI subclasses are Device instances" do
    [ devices(:camera_entrance), devices(:core_switch),
      devices(:main_router), devices(:reception_pc), devices(:file_server) ].each do |d|
      assert_kind_of Device, d, "Expected #{d.class} to be a Device"
    end
  end

  # ---------------------------------------------------------------------------
  # STI — model_name override (routing)
  # ---------------------------------------------------------------------------

  test "Camera model_name is Device" do
    assert_equal "Device", Camera.model_name.name
  end

  test "Switch model_name is Device" do
    assert_equal "Device", Switch.model_name.name
  end

  test "Router model_name is Device" do
    assert_equal "Device", Router.model_name.name
  end

  test "Pc model_name is Device" do
    assert_equal "Device", Pc.model_name.name
  end

  test "Server model_name is Device" do
    assert_equal "Device", Server.model_name.name
  end

  # ---------------------------------------------------------------------------
  # Constants
  # ---------------------------------------------------------------------------

  test "TYPES contains exactly the five device types" do
    assert_equal %w[Camera Switch Router Pc Server], Device::TYPES
  end

  test "STATUSES contains exactly the three statuses" do
    assert_equal %w[active inactive maintenance], Device::STATUSES
  end

  test "TYPE_LABELS maps Pc to PC" do
    assert_equal "PC", Device::TYPE_LABELS["Pc"]
  end

  test "TYPE_LABELS has an entry for every TYPE" do
    Device::TYPES.each do |type|
      assert Device::TYPE_LABELS.key?(type), "Missing TYPE_LABELS entry for #{type}"
    end
  end

  # ---------------------------------------------------------------------------
  # Optional attributes can be nil
  # ---------------------------------------------------------------------------

  test "valid without optional attributes" do
    device = Camera.new(name: "Minimal")
    assert device.valid?
    assert_nil device.brand
    assert_nil device.model_number
    assert_nil device.serial_number
    assert_nil device.ip_address
    assert_nil device.mac_address
    assert_nil device.location
    assert_nil device.notes
    assert_nil device.purchased_at
    assert_nil device.warranty_expires_at
  end

  test "persists all optional attributes" do
    device = Camera.create!(
      name: "Full Camera",
      brand: "Hikvision",
      model_number: "DS-2CD2143G2-I",
      serial_number: "ABC123",
      ip_address: "10.0.0.1",
      mac_address: "AA:BB:CC:DD:EE:FF",
      location: "Roof",
      notes: "PTZ camera",
      purchased_at: Date.new(2023, 1, 1),
      warranty_expires_at: Date.new(2026, 1, 1),
      status: "active"
    )

    device.reload
    assert_equal "Hikvision", device.brand
    assert_equal "DS-2CD2143G2-I", device.model_number
    assert_equal "ABC123", device.serial_number
    assert_equal "10.0.0.1", device.ip_address
    assert_equal "AA:BB:CC:DD:EE:FF", device.mac_address
    assert_equal "Roof", device.location
    assert_equal "PTZ camera", device.notes
    assert_equal Date.new(2023, 1, 1), device.purchased_at
    assert_equal Date.new(2026, 1, 1), device.warranty_expires_at
  end

  # ---------------------------------------------------------------------------
  # Persistence
  # ---------------------------------------------------------------------------

  test "saves and reloads with correct type" do
    Camera.create!(name: "Persist Test")
    reloaded = Device.find_by(name: "Persist Test")
    assert_instance_of Camera, reloaded
    assert_equal "Camera", reloaded.type
  end

  test "Device.all returns all types" do
    types = Device.all.map(&:type).uniq.sort
    assert_includes types, "Camera"
    assert_includes types, "Switch"
  end
end
