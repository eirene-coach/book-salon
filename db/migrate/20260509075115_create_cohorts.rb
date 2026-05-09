class CreateCohorts < ActiveRecord::Migration[8.1]
  def change
    create_table :cohorts do |t|
      t.references :program, null: false, foreign_key: true
      t.date :start_date
      t.string :status, null: false, default: "recruiting"

      t.timestamps
    end
  end
end
