class CreateInterventions < ActiveRecord::Migration[8.1]
  def change
    create_table :interventions do |t|
      t.references :device, null: false, foreign_key: true
      t.date :intervened_at, null: false
      t.string :intervention_type, null: false
      t.text :description, null: false
      t.text :parts_replaced

      t.timestamps
    end
  end
end
