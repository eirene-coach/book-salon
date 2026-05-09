class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :cohort
  has_many :responses, dependent: :destroy

  def paid?
    payment_status == "paid"
  end
end
