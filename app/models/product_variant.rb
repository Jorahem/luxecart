class ProductVariant < ApplicationRecord
  belongs_to :product

  validates :sku, presence: true, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where('stock_quantity > ?', 0) }

  def display_name
    parts = []
    parts << option1_value if option1_value.present?
    parts << option2_value if option2_value.present?
    parts << option3_value if option3_value.present?
    parts.any? ? parts.join(' / ') : name || 'Default'
  end

  def in_stock?
    stock_quantity.positive?
  end

  def effective_price
    price || product.price
  end
end
