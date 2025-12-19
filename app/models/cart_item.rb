class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id }
  validate :product_in_stock

  def total_price
    product.price * quantity
  end

  private

  def product_in_stock
    if product && quantity > product.stock_quantity
      errors.add(:quantity, "only #{product.stock_quantity} available in stock")
    end
  end
end