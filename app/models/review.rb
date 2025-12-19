class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  enum status: { pending: 0, approved: 1, rejected: 2 }

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :product_id }

  scope :approved, -> { where(status: :approved) }
  scope :recent, -> { order(created_at: :desc) }
end