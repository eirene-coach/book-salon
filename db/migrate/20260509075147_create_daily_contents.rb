class CreateDailyContents < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_contents do |t|
      t.references :cohort, null: false, foreign_key: true
      t.integer :day_number
      t.string :video_url
      t.text :question_text

      t.timestamps
    end
  end
end
