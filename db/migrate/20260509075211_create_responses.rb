class CreateResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :responses do |t|
      t.references :enrollment, null: false, foreign_key: true
      t.references :daily_content, null: false, foreign_key: true
      t.text :content
      t.text :feedback_text
      t.datetime :feedback_at
      t.boolean :is_public, null: false, default: false

      t.timestamps
    end
  end
end
