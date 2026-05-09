# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_09_075211) do
  create_table "cohorts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "program_id", null: false
    t.date "start_date"
    t.string "status", default: "recruiting", null: false
    t.datetime "updated_at", null: false
    t.index ["program_id"], name: "index_cohorts_on_program_id"
  end

  create_table "daily_contents", force: :cascade do |t|
    t.integer "cohort_id", null: false
    t.datetime "created_at", null: false
    t.integer "day_number"
    t.text "question_text"
    t.datetime "updated_at", null: false
    t.string "video_url"
    t.index ["cohort_id"], name: "index_daily_contents_on_cohort_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "cohort_id", null: false
    t.datetime "created_at", null: false
    t.string "payment_status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["cohort_id"], name: "index_enrollments_on_cohort_id"
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "programs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration_weeks"
    t.integer "price"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "responses", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "daily_content_id", null: false
    t.integer "enrollment_id", null: false
    t.datetime "feedback_at"
    t.text "feedback_text"
    t.boolean "is_public", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["daily_content_id"], name: "index_responses_on_daily_content_id"
    t.index ["enrollment_id"], name: "index_responses_on_enrollment_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "member", null: false
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "cohorts", "programs"
  add_foreign_key "daily_contents", "cohorts"
  add_foreign_key "enrollments", "cohorts"
  add_foreign_key "enrollments", "users"
  add_foreign_key "responses", "daily_contents"
  add_foreign_key "responses", "enrollments"
end
