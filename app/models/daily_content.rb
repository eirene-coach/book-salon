class DailyContent < ApplicationRecord
  belongs_to :cohort
  has_many :responses, dependent: :destroy
end
