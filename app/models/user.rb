class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :lockable, :trackable, :timeoutable
  has_many :instructed_courses, class_name: "Course", foreign_key: :instructor_id, dependent: :nullify
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :lesson_completions, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :role, presence: true

  enum :role, { student: 0, instructor: 1, admin: 2 }

  attr_accessor :login

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    if login
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
