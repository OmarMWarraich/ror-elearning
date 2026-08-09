class Lesson < ApplicationRecord
  belongs_to :course

  has_many :lesson_completions, dependent: :destroy

  has_rich_text :content

  validates :title, :course, presence: true
  validates :slug, uniqueness: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_slug, on: :create

  enum status: { draft: 0, published: 1, archived: 2 }

  scope :ordered, -> { order(:position) }
  scope :published, -> { where(status: :published) }
end
