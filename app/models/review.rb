class Review < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates :rating, presence: true, numericality: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :course_id }
  validates :comment, length: { maximum: 2000 }
  validate :user_must_be_enrolled, on: :create

  private

  def user_must_be_enrolled
    return if course.enrolled?(user) || course.instructor == user

    errors.add(:user, "must be enrolled in the course to leave a review")
  end
end
