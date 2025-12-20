class ProductVariant < ApplicationRecord
  belongs_to :product
  
  validates :sku, presence: true, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  
  def in_stock?
    stock_quantity > 0
  end
  
  def low_stock?
    stock_quantity > 0 && stock_quantity < 10
  end
end
