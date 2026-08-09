class Review < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates :rating, presence: true, numericality: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :course_id }
  validates :comment, length: { maximum: 2000 }
end
