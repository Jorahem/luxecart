class OrderTrackingEvent < ApplicationRecord
  belongs_to :order

  validates :status, :happened_at, presence: true

  default_scope { order(happened_at: :asc) }
end