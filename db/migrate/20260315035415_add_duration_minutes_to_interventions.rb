class AddDurationMinutesToInterventions < ActiveRecord::Migration[8.1]
  def change
    add_column :interventions, :duration_minutes, :integer
  end
end
