class InterventionsController < ApplicationController
  before_action :set_device, only: %i[new create]
  before_action :set_intervention, only: %i[show edit update destroy]

  def index
    @device = Device.find(params[:device_id]) if params[:device_id].present?
    @interventions = if @device
      @device.interventions
    else
      Intervention.all
    end
    @interventions = @interventions.includes(:device)

    respond_to do |format|
      format.html
      format.xlsx do
        filename = @device ? "interventions_#{@device.name.parameterize}.xlsx" : "interventions.xlsx"
        response.headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
      end
    end
  end

  def show
  end

  def new
    @intervention = Intervention.new(device: @device, intervened_at: Date.today)
  end

  def edit
  end

  def create
    @intervention = Intervention.new(intervention_params)
    @intervention.device = @device if @device

    if @intervention.save
      if @device
        redirect_to @device, notice: "Intervention was successfully recorded."
      else
        redirect_to interventions_path, notice: "Intervention was successfully recorded."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @intervention.update(intervention_params)
      redirect_to @intervention, notice: "Intervention was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    device = @intervention.device
    @intervention.destroy!
    redirect_to device, notice: "Intervention was successfully deleted."
  end

  private

  def set_device
    @device = Device.find(params[:device_id]) if params[:device_id].present?
  end

  def set_intervention
    @intervention = Intervention.find(params[:id])
  end

  def intervention_params
    params.expect(intervention: [
      :device_id, :intervened_at, :intervention_type, :description, :parts_replaced, :duration_minutes
    ])
  end
end
