class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy

  # simple helper: total price (uses decimal price if present, or cents)
  def total_amount
    cart_items.includes(:product).sum do |item|
      if item.unit_price_decimal
        item.unit_price_decimal * item.quantity
      else
        (item.unit_price_cents || 0) / 100.0 * item.quantity
      end
    end
  end
end