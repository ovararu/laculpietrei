Camera.find_or_create_by!(name: "Camera - Entrance") do |d|
  d.brand = "Hikvision"
  d.model_number = "DS-2CD2143G2-I"
  d.serial_number = "SN-CAM-001"
  d.ip_address = "192.168.1.101"
  d.mac_address = "AA:BB:CC:01:01:01"
  d.location = "Main Entrance"
  d.status = "active"
  d.purchased_at = "2023-06-15"
  d.warranty_expires_at = "2026-06-15"
end

Camera.find_or_create_by!(name: "Camera - Parking") do |d|
  d.brand = "Dahua"
  d.model_number = "IPC-HDW2831T-AS"
  d.serial_number = "SN-CAM-002"
  d.ip_address = "192.168.1.102"
  d.mac_address = "AA:BB:CC:01:01:02"
  d.location = "Parking Lot"
  d.status = "active"
  d.purchased_at = "2023-06-15"
  d.warranty_expires_at = "2026-06-15"
end

Switch.find_or_create_by!(name: "Core Switch") do |d|
  d.brand = "Cisco"
  d.model_number = "Catalyst 2960-X"
  d.serial_number = "SN-SW-001"
  d.ip_address = "192.168.1.2"
  d.mac_address = "AA:BB:CC:02:01:01"
  d.location = "Server Room"
  d.status = "active"
  d.purchased_at = "2022-01-10"
  d.warranty_expires_at = "2025-01-10"
end

Switch.find_or_create_by!(name: "Floor 2 Switch") do |d|
  d.brand = "TP-Link"
  d.model_number = "TL-SG1024D"
  d.serial_number = "SN-SW-002"
  d.ip_address = "192.168.1.3"
  d.mac_address = "AA:BB:CC:02:01:02"
  d.location = "Floor 2, Rack Cabinet"
  d.status = "maintenance"
  d.purchased_at = "2021-05-20"
end

Router.find_or_create_by!(name: "Main Router") do |d|
  d.brand = "MikroTik"
  d.model_number = "RB4011iGS+RM"
  d.serial_number = "SN-RT-001"
  d.ip_address = "192.168.1.1"
  d.mac_address = "AA:BB:CC:03:01:01"
  d.location = "Server Room"
  d.status = "active"
  d.purchased_at = "2022-01-10"
  d.warranty_expires_at = "2025-01-10"
end

Pc.find_or_create_by!(name: "Reception PC") do |d|
  d.brand = "Dell"
  d.model_number = "OptiPlex 7090"
  d.serial_number = "SN-PC-001"
  d.ip_address = "192.168.1.50"
  d.mac_address = "AA:BB:CC:04:01:01"
  d.location = "Reception"
  d.status = "active"
  d.purchased_at = "2022-09-01"
  d.warranty_expires_at = "2025-09-01"
end

Pc.find_or_create_by!(name: "Accounting PC") do |d|
  d.brand = "HP"
  d.model_number = "EliteDesk 800 G6"
  d.serial_number = "SN-PC-002"
  d.ip_address = "192.168.1.51"
  d.mac_address = "AA:BB:CC:04:01:02"
  d.location = "Accounting Office"
  d.status = "inactive"
  d.purchased_at = "2020-03-15"
  d.notes = "Scheduled for replacement"
end

Server.find_or_create_by!(name: "File Server") do |d|
  d.brand = "Dell"
  d.model_number = "PowerEdge R750"
  d.serial_number = "SN-SRV-001"
  d.ip_address = "192.168.1.10"
  d.mac_address = "AA:BB:CC:05:01:01"
  d.location = "Server Room, Rack 1"
  d.status = "active"
  d.purchased_at = "2023-01-20"
  d.warranty_expires_at = "2028-01-20"
end
