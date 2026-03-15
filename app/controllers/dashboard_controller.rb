class DashboardController < ApplicationController
  def index
    @total      = Device.count
    @by_type    = Device.group(:type).count
    @by_status  = Device.group(:status).count
    @active     = @by_status.fetch("active", 0)
    @inactive   = @by_status.fetch("inactive", 0)
    @maintenance = @by_status.fetch("maintenance", 0)
    @warranty_expiring = Device.where(warranty_expires_at: Date.today..90.days.from_now)
                               .order(:warranty_expires_at)
    @unconnected = Device.where(parent_device_id: nil).count
  end
end
