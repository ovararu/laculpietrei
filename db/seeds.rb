# Create all devices first, then wire up connections below.

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

# Wire up topology connections
# Main Router (top-level, no parent)
#   └── Core Switch
#         ├── Camera - Entrance
#         ├── Camera - Parking
#         ├── Reception PC
#         └── File Server
#   └── Floor 2 Switch
#         └── Accounting PC

router       = Router.find_by!(name: "Main Router")
core_switch  = Switch.find_by!(name: "Core Switch")
floor_switch = Switch.find_by!(name: "Floor 2 Switch")

core_switch.update!(parent_device: router)
floor_switch.update!(parent_device: router)

Camera.find_by!(name: "Camera - Entrance").update!(parent_device: core_switch)
Camera.find_by!(name: "Camera - Parking").update!(parent_device: core_switch)
Pc.find_by!(name: "Reception PC").update!(parent_device: core_switch)
Server.find_by!(name: "File Server").update!(parent_device: core_switch)
Pc.find_by!(name: "Accounting PC").update!(parent_device: floor_switch)

# Sample interventions
cam_entrance = Camera.find_by!(name: "Camera - Entrance")
floor_switch_dev = Switch.find_by!(name: "Floor 2 Switch")
server = Server.find_by!(name: "File Server")
reception_pc = Pc.find_by!(name: "Reception PC")

Intervention.find_or_create_by!(device: cam_entrance, intervened_at: "2025-11-10", intervention_type: "breakdown") do |i|
  i.description = "Camera stopped recording after power outage. Reset power supply and reconfigured NVR stream."
  i.parts_replaced = "Power supply unit"
end.update!(duration_minutes: 90)

Intervention.find_or_create_by!(device: cam_entrance, intervened_at: "2025-08-15", intervention_type: "maintenance") do |i|
  i.description = "Cleaned lens, checked mounting bracket, verified motion detection zones. All OK."
end.update!(duration_minutes: 30)

Intervention.find_or_create_by!(device: floor_switch_dev, intervened_at: "2025-12-01", intervention_type: "configuration") do |i|
  i.description = "Configured VLAN 20 for new IP phones. Updated port assignments and trunk uplinks."
end.update!(duration_minutes: 60)

Intervention.find_or_create_by!(device: floor_switch_dev, intervened_at: "2025-09-05", intervention_type: "breakdown") do |i|
  i.description = "Port 8 failed — no link light. Replaced SFP module."
  i.parts_replaced = "SFP 1G module (TP-Link TL-SM311LS)"
end.update!(duration_minutes: 45)

Intervention.find_or_create_by!(device: server, intervened_at: "2025-10-20", intervention_type: "upgrade") do |i|
  i.description = "Upgraded RAM from 32GB to 64GB. Extended OS partition. Updated firmware to latest version."
  i.parts_replaced = "2x 16GB DDR4 ECC RDIMM"
end.update!(duration_minutes: 120)

Intervention.find_or_create_by!(device: server, intervened_at: "2025-07-14", intervention_type: "maintenance") do |i|
  i.description = "Annual maintenance: cleaned dust filters, checked RAID health (all disks OK), verified backup schedule."
end.update!(duration_minutes: 60)

Intervention.find_or_create_by!(device: reception_pc, intervened_at: "2026-01-08", intervention_type: "breakdown") do |i|
  i.description = "PC would not boot — corrupted Windows profile. Repaired profile, restored user data from backup."
end.update!(duration_minutes: 75)
