class Course < ApplicationRecord
  has_many :lessons, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments
  belongs_to :instructor, class_name: 'User'

  validates :title, presence: true
  validates :description, presence: true
  validates :instructor_id, presence: true
  
  enum status: { draft: 0, published: 1, archived: 2 }
end
