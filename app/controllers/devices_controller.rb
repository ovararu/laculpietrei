class DevicesController < ApplicationController
  before_action :set_device, only: %i[show edit update destroy]

  def index
    @devices = if params[:type].present? && Device::TYPES.include?(params[:type])
      Device.where(type: params[:type]).order(:name)
    else
      Device.all.order(:name)
    end
    @current_type = params[:type]

    respond_to do |format|
      format.html
      format.xlsx do
        filename = @current_type ? "devices_#{@current_type.downcase}.xlsx" : "devices.xlsx"
        response.headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
      end
    end
  end

  def show
  end

  def new
    klass = device_class_from(params[:type])
    @device = klass.new
  end

  def edit
  end

  def create
    klass = device_class_from(device_params[:type])
    @device = klass.new(device_params.except(:type))

    if @device.save
      redirect_to @device, notice: "Device was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    new_type = device_params[:type]
    if new_type.present? && Device::TYPES.include?(new_type) && @device.type != new_type
      @device = @device.becomes(new_type.constantize)
      @device.type = new_type
    end
    if @device.update(device_params.except(:type))
      redirect_to @device, notice: "Device was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @device.destroy!
    redirect_to devices_path, notice: "Device was successfully deleted."
  end

  private

  def set_device
    @device = Device.find(params[:id])
  end

  DEVICE_CLASSES = {
    "Camera" => Camera, "Switch" => Switch, "Router" => Router,
    "Pc" => Pc, "Server" => Server
  }.freeze

  def device_class_from(type)
    DEVICE_CLASSES.fetch(type, Device)
  end

  def device_params
    params.expect(device: [
      :type, :name, :brand, :model_number, :serial_number,
      :ip_address, :mac_address, :location, :status,
      :notes, :purchased_at, :warranty_expires_at, :parent_device_id,
      :username, :password
    ])
  end
end
