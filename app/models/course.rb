class Course < ApplicationRecord
  belongs_to :instructor, class_name: "User"
  belongs_to :category, optional: true

  has_many :lessons, -> { order(:position) }, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user
  has_many :reviews, dependent: :destroy

  has_rich_text :description

  validates :title, :instructor, presence: true
  validates :description, presence: true, on: :create
  validates :title, :slug, uniqueness: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_slug, on: :create
  before_validation :set_default_status, on: :create

  enum :status, { draft: 0, published: 1, archived: 2 }

  scope :published, -> { where(status: :published) }
  scope :free, -> { where(price_cents: 0) }
  scope :paid, -> { where("price_cents > 0") }
  scope :recent, -> { order(created_at: :desc) }

  def average_rating
    reviews.average(:rating).to_f.round(1)
  end

  def enrolled?(user)
    enrollments.exists?(user: user)
  end

  private

  def generate_slug
    self.slug ||= title.to_s.parameterize
  end

  def set_default_status
    self.status ||= :draft
  end
end
