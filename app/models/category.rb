class Category < ApplicationRecord
  has_many :courses, dependent: :nullify

  validates :name, :slug, presence: true, uniqueness: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_slug, on: :create

  scope :ordered, -> { order(:position, :name) }

  private

  def generate_slug
    self.slug ||= name.to_s.parameterize
  end
end
