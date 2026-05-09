class Cohort < ApplicationRecord
  belongs_to :program
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments
  has_many :daily_contents, dependent: :destroy
end
