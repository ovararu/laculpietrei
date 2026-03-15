require "application_system_test_case"

class DevicesTest < ApplicationSystemTestCase
  # ---------------------------------------------------------------------------
  # Index page
  # ---------------------------------------------------------------------------

  test "visiting the index shows all devices" do
    visit devices_path

    assert_selector "h1", text: "Devices"
    assert_text devices(:camera_entrance).name
    assert_text devices(:core_switch).name
    assert_text devices(:main_router).name
    assert_text devices(:reception_pc).name
    assert_text devices(:file_server).name
  end

  test "index shows type filter tabs" do
    visit devices_path

    assert_link "All"
    assert_link "Camera"
    assert_link "Switch"
    assert_link "Router"
    assert_link "PC"
    assert_link "Server"
  end

  test "clicking Camera filter shows only cameras" do
    visit devices_path
    click_link "Camera"

    assert_text devices(:camera_entrance).name
    assert_text devices(:camera_parking).name
    assert_no_text devices(:core_switch).name
    assert_no_text devices(:reception_pc).name
  end

  test "clicking Server filter shows only servers" do
    visit devices_path
    click_link "Server"

    assert_text devices(:file_server).name
    assert_no_text devices(:camera_entrance).name
  end

  test "clicking All after a filter shows all devices" do
    visit devices_path(type: "Camera")
    click_link "All"

    assert_text devices(:camera_entrance).name
    assert_text devices(:core_switch).name
  end

  test "index shows status badges" do
    visit devices_path

    assert_text "Active"
    assert_text "Inactive"
    assert_text "Maintenance"
  end

  test "index shows Add Device button" do
    visit devices_path
    assert_link "Add Device"
  end

  # ---------------------------------------------------------------------------
  # Show page
  # ---------------------------------------------------------------------------

  test "clicking device name navigates to show page" do
    visit devices_path
    click_link devices(:camera_entrance).name

    assert_selector "h1", text: "Camera - Entrance"
    assert_text "Hikvision"
    assert_text "192.168.1.101"
    assert_text "Main Entrance"
  end

  test "show page displays type label" do
    visit device_path(devices(:reception_pc))
    assert_text "PC"
  end

  test "show page displays notes when present" do
    visit device_path(devices(:file_server))
    assert_text "Scheduled for upgrade"
  end

  test "show page has Edit and Delete buttons" do
    visit device_path(devices(:camera_entrance))
    assert_link "Edit"
    assert_button "Delete"
  end

  test "back link on show page navigates to index" do
    visit device_path(devices(:camera_entrance))
    click_link "← Back to devices"
    assert_current_path devices_path
  end

  # ---------------------------------------------------------------------------
  # Create device
  # ---------------------------------------------------------------------------

  test "navigating to new device form via Add Device button" do
    visit devices_path
    click_link "Add Device"
    assert_selector "h1", text: "Add Device"
    assert_selector "form"
  end

  test "create a new camera successfully" do
    visit new_device_path

    select "Camera", from: "Device Type"
    fill_in "Name", with: "System Test Camera"
    fill_in "Brand", with: "Axis"
    fill_in "IP Address", with: "10.0.0.99"
    fill_in "Location", with: "Rooftop"
    select "Active", from: "Status"

    click_button "Create Device"

    assert_text "Device was successfully created."
    assert_text "System Test Camera"
    assert_text "Axis"
    assert_text "10.0.0.99"
    assert_text "Rooftop"
  end

  test "create a new server with all fields" do
    visit new_device_path

    select "Server", from: "Device Type"
    fill_in "Name", with: "System Test Server"
    fill_in "Brand", with: "Dell"
    fill_in "Model", with: "PowerEdge R650"
    fill_in "Serial Number", with: "SYS-SRV-001"
    fill_in "IP Address", with: "192.168.1.200"
    fill_in "MAC Address", with: "DE:AD:BE:EF:00:01"
    fill_in "Location", with: "Rack 5"
    select "Maintenance", from: "Status"
    fill_in "Notes", with: "Being configured"

    click_button "Create Device"

    assert_text "Device was successfully created."
    assert_text "System Test Server"
    assert_text "PowerEdge R650"
    assert_text "SYS-SRV-001"
  end

  test "create device with missing name shows validation error" do
    visit new_device_path

    select "Router", from: "Device Type"
    # Leave Name blank

    click_button "Create Device"

    assert_text "can't be blank"
    assert_selector "form"
  end

  test "cancel button on new form returns to index" do
    visit new_device_path
    click_link "Cancel"
    assert_current_path devices_path
  end

  # ---------------------------------------------------------------------------
  # Edit device
  # ---------------------------------------------------------------------------

  test "edit device changes name" do
    visit device_path(devices(:camera_entrance))
    click_link "Edit"

    fill_in "Name", with: "Camera - Front Door"
    click_button "Update Device"

    assert_text "Device was successfully updated."
    assert_text "Camera - Front Door"
  end

  test "edit device changes status" do
    visit device_path(devices(:camera_entrance))
    click_link "Edit"

    select "Maintenance", from: "Status"
    click_button "Update Device"

    assert_text "Device was successfully updated."
    assert_text "Maintenance"
  end

  test "edit device with blank name shows error" do
    visit edit_device_path(devices(:camera_entrance))

    fill_in "Name", with: ""
    click_button "Update Device"

    assert_text "can't be blank"
  end

  test "cancel on edit returns to show page" do
    visit edit_device_path(devices(:camera_entrance))
    click_link "Cancel"
    assert_current_path devices_path
  end

  # ---------------------------------------------------------------------------
  # Delete device
  # ---------------------------------------------------------------------------

  test "delete device removes it from index" do
    device_name = devices(:camera_parking).name

    visit devices_path
    assert_text device_name

    visit device_path(devices(:camera_parking))
    accept_confirm { click_button "Delete" }

    assert_current_path devices_path
    assert_text "Device was successfully deleted."
    assert_no_text device_name
  end

  # ---------------------------------------------------------------------------
  # Dark mode toggle
  # ---------------------------------------------------------------------------

  test "dark mode toggle button is visible" do
    visit devices_path
    assert_selector "button[data-controller='theme']"
  end

  test "clicking theme toggle adds dark class to html element" do
    visit devices_path
    assert_no_selector "html.dark"
    find("button[data-controller='theme']").click
    assert_selector "html.dark"
  end

  test "clicking theme toggle twice removes dark class" do
    visit devices_path
    find("button[data-controller='theme']").click
    find("button[data-controller='theme']").click
    assert_no_selector "html.dark"
  end
end
