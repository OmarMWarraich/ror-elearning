class User < ApplicationRecord
  has_many :instructed_courses, class_name: "Course", foreign_key: :instructor_id, dependent: :nullify
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :lesson_completions, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :email, :username, presence: true, uniqueness: true
  validates :role, presence: true

  enum :role, { student: 0, instructor: 1, admin: 2 }

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
