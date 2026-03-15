class Device < ApplicationRecord
  TYPES = %w[Camera Switch Router Pc Server].freeze
  STATUSES = %w[active inactive maintenance].freeze

  TYPE_LABELS = {
    "Camera" => "Camera",
    "Switch" => "Switch",
    "Router" => "Router",
    "Pc" => "PC",
    "Server" => "Server"
  }.freeze

  def self.inherited(subclass)
    super
    subclass.instance_variable_set(:@_model_name, ActiveModel::Name.new(Device))
  end

  validates :name, presence: true
  validates :type, inclusion: { in: TYPES }
  validates :status, inclusion: { in: STATUSES }

  def type_label
    TYPE_LABELS.fetch(type, type)
  end
end
