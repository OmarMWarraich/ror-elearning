class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course

  has_many :lesson_completions, dependent: :destroy

  validates :user_id, uniqueness: { scope: :course_id }
  validates :progress_percentage, numericality: { in: 0..100 }

  before_validation :set_enrolled_at, on: :create

  enum status: { active: 0, completed: 1, dropped: 2 }

  scope :active, -> { where(status: :active) }
  scope :completed, -> { where(status: :completed) }

  def update_progress!
    total_lessons = course.lessons.published.count
    completed_lessons = lesson_completions.count
    percentage = total_lessons.positive? ? (completed_lessons * 100 / total_lessons) : 0

    update!(progress_percentage: percentage, completed_at: (percentage == 100 ? Time.current : nil))
  end

  private

  def set_enrolled_at
    self.enrolled_at ||= Time.current
  end
end
