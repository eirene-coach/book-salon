class Program < ApplicationRecord
  has_many :cohorts, dependent: :destroy
  has_many :enrollments, through: :cohorts
end
