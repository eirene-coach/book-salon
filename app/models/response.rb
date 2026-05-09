class Response < ApplicationRecord
  belongs_to :enrollment
  belongs_to :daily_content
  has_one :user, through: :enrollment
end
