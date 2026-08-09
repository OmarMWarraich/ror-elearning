class LessonCompletion < ApplicationRecord
  belongs_to :user
  belongs_to :lesson
  belongs_to :enrollment

  validates :user_id, uniqueness: { scope: :lesson_id }

  before_validation :set_completed_at, on: :create

  after_create :update_enrollment_progress

  private

  def set_completed_at
    self.completed_at ||= Time.current
  end

  def update_enrollment_progress
    enrollment.update_progress!
  end
end
