class Intervention < ApplicationRecord
  TYPES = %w[breakdown maintenance installation configuration upgrade].freeze

  TYPE_LABELS = {
    "breakdown"     => "Breakdown",
    "maintenance"   => "Preventive Maintenance",
    "installation"  => "Installation",
    "configuration" => "Configuration",
    "upgrade"       => "Upgrade"
  }.freeze

  TYPE_COLORS = {
    "breakdown"     => "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400",
    "maintenance"   => "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400",
    "installation"  => "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400",
    "configuration" => "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400",
    "upgrade"       => "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400"
  }.freeze

  belongs_to :device

  validates :intervened_at, presence: true
  validates :intervention_type, inclusion: { in: TYPES }
  validates :description, presence: true

  default_scope { order(intervened_at: :desc, created_at: :desc) }

  def type_label
    TYPE_LABELS.fetch(intervention_type, intervention_type)
  end

  def type_color
    TYPE_COLORS.fetch(intervention_type, "bg-gray-100 text-gray-700")
  end
end
