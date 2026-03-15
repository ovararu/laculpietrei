class BillingController < ApplicationController
  def index
    @year  = (params[:year]  || Date.today.year).to_i
    @month = (params[:month] || Date.today.month).to_i

    @period_start = Date.new(@year, @month, 1)
    @period_end   = @period_start.end_of_month

    @interventions = Intervention
      .where(intervened_at: @period_start..@period_end)
      .includes(:device)

    @total_minutes = @interventions.sum(:duration_minutes)

    @by_device = @interventions
      .group_by(&:device)
      .transform_values { |list|
        {
          interventions: list,
          total_minutes: list.sum { |i| i.duration_minutes.to_i }
        }
      }
      .sort_by { |_device, data| -data[:total_minutes] }
  end
end
