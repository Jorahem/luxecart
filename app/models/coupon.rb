class Coupon < ApplicationRecord
  enum discount_type: { percentage: 0, fixed_amount: 1 }

  validates :code, presence: true, uniqueness: true
  validates :discount_value, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }

  def calculate_discount(order_total)
    return 0 unless active?
    percentage? ? (order_total * discount_value / 100).round(2) : [discount_value, order_total].min
  end
end