require "test_helper"

class TopologyControllerTest < ActionDispatch::IntegrationTest
  test "index renders topology page" do
    get topology_path
    assert_response :success
  end

  test "graph_data returns json" do
    get topology_graph_data_path, headers: { "Accept" => "application/json" }
    assert_response :success
    assert_includes response.content_type, "application/json"
  end

  test "graph_data includes nodes and edges keys" do
    get topology_graph_data_path, headers: { "Accept" => "application/json" }
    data = JSON.parse(response.body)
    assert data.key?("nodes"), "Response missing 'nodes' key"
    assert data.key?("edges"), "Response missing 'edges' key"
  end

  test "graph_data nodes include required fields" do
    get topology_graph_data_path, headers: { "Accept" => "application/json" }
    nodes = JSON.parse(response.body)["nodes"]
    assert nodes.any?, "Expected at least one node"
    node = nodes.first
    assert node.key?("id"),    "Node missing 'id'"
    assert node.key?("label"), "Node missing 'label'"
    assert node.key?("group"), "Node missing 'group'"
    assert node.key?("color"), "Node missing 'color'"
    assert node.key?("shape"), "Node missing 'shape'"
  end

  test "graph_data node label includes ip address when present" do
    device = devices(:camera_entrance)
    device.update!(ip_address: "192.168.1.101")

    get topology_graph_data_path, headers: { "Accept" => "application/json" }
    nodes = JSON.parse(response.body)["nodes"]
    node  = nodes.find { |n| n["id"] == device.id }

    assert_includes node["label"], device.name
    assert_includes node["label"], "192.168.1.101"
  end

  test "graph_data node label shows only name when ip is blank" do
    device = devices(:camera_entrance)
    device.update!(ip_address: nil)

    get topology_graph_data_path, headers: { "Accept" => "application/json" }
    nodes = JSON.parse(response.body)["nodes"]
    node  = nodes.find { |n| n["id"] == device.id }

    assert_equal device.name, node["label"]
  end

  test "graph_data edges connect parent and child devices" do
    parent = devices(:core_switch)
    child  = devices(:camera_entrance)
    child.update!(parent_device: parent)

    get topology_graph_data_path, headers: { "Accept" => "application/json" }
    edges = JSON.parse(response.body)["edges"]

    edge = edges.find { |e| e["from"] == parent.id && e["to"] == child.id }
    assert edge, "Expected edge from core_switch to camera_entrance"
  end

  test "graph_data edges empty when no connections defined" do
    Device.update_all(parent_device_id: nil)

    get topology_graph_data_path, headers: { "Accept" => "application/json" }
    edges = JSON.parse(response.body)["edges"]

    assert_empty edges
  end

  test "graph_data node color reflects device type" do
    get topology_graph_data_path, headers: { "Accept" => "application/json" }
    nodes = JSON.parse(response.body)["nodes"]

    router_node = nodes.find { |n| n["group"] == "Router" }
    assert_equal "#10B981", router_node["color"]["background"]

    camera_node = nodes.find { |n| n["group"] == "Camera" }
    assert_equal "#3B82F6", camera_node["color"]["background"]
  end

  test "graph_data node shape reflects device type" do
    get topology_graph_data_path, headers: { "Accept" => "application/json" }
    nodes = JSON.parse(response.body)["nodes"]

    shapes = nodes.index_by { |n| n["group"] }
    assert_equal "diamond", shapes["Router"]["shape"]
    assert_equal "hexagon", shapes["Switch"]["shape"]
    assert_equal "box",     shapes["Server"]["shape"]
    assert_equal "dot",     shapes["Camera"]["shape"]
    assert_equal "square",  shapes["Pc"]["shape"]
  end

  test "graph_data inactive device has dashed border" do
    device = devices(:camera_entrance)
    device.update!(status: "inactive")

    get topology_graph_data_path, headers: { "Accept" => "application/json" }
    nodes = JSON.parse(response.body)["nodes"]
    node  = nodes.find { |n| n["id"] == device.id }

    assert node["borderDashes"], "Expected dashed border for inactive device"
  end
end
