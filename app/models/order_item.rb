class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_save :set_unit_price, :calculate_total_price, :capture_product_details

  def subtotal
    quantity * unit_price
  end

  private

  def set_unit_price
    self.unit_price ||= product.price if product
  end

  def calculate_total_price
    self.total_price = quantity * unit_price
  end

  def capture_product_details
    if product
      self.product_name = product.name
      self.product_sku = product.sku
    end
  end
end