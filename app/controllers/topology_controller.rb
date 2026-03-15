class TopologyController < ApplicationController
  def index
  end

  def graph_data
    type_colors = {
      "Camera"  => { background: "#3B82F6", border: "#1D4ED8" },
      "Switch"  => { background: "#8B5CF6", border: "#6D28D9" },
      "Router"  => { background: "#10B981", border: "#047857" },
      "Pc"      => { background: "#F59E0B", border: "#D97706" },
      "Server"  => { background: "#EF4444", border: "#B91C1C" }
    }

    status_border = {
      "active"      => nil,
      "inactive"    => "#6B7280",
      "maintenance" => "#F59E0B"
    }

    nodes = Device.all.map do |d|
      colors = type_colors.fetch(d.type, { background: "#9CA3AF", border: "#6B7280" })
      border = status_border[d.status] || colors[:border]
      {
        id: d.id,
        label: d.ip_address.present? ? "#{d.name}\n#{d.ip_address}" : d.name,
        title: "#{d.type_label} | #{d.status}#{d.ip_address.present? ? "\n#{d.ip_address}" : ""}#{d.location.present? ? "\n#{d.location}" : ""}",
        group: d.type,
        color: { background: colors[:background], border: border, highlight: { background: colors[:background], border: "#1E40AF" } },
        font: { color: "#FFFFFF", size: 13, multi: "html", bold: { size: 13 } },
        borderWidth: d.status == "active" ? 2 : 3,
        borderDashes: d.status == "inactive" ? [ 5, 5 ] : false,
        shape: shape_for(d.type)
      }
    end

    edges = Device.where.not(parent_device_id: nil).map do |d|
      { from: d.parent_device_id, to: d.id, arrows: "to", color: { color: "#94A3B8" }, smooth: { type: "cubicBezier" } }
    end

    render json: { nodes: nodes, edges: edges }
  end

  private

  def shape_for(type)
    case type
    when "Router"  then "diamond"
    when "Switch"  then "hexagon"
    when "Server"  then "box"
    when "Camera"  then "dot"
    when "Pc"      then "square"
    else "ellipse"
    end
  end
end
