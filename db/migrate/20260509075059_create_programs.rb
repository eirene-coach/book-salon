class CreatePrograms < ActiveRecord::Migration[8.1]
  def change
    create_table :programs do |t|
      t.string :title
      t.text :description
      t.integer :price
      t.integer :duration_weeks

      t.timestamps
    end
  end
end
