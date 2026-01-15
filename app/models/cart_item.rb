class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than_or_equal_to: 1 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :set_price_if_missing, on: :create

  # Safe accessor for the unit price.
  # If the DB column :price exists and is set, use it.
  # Otherwise fall back to the associated product's price (if present).
  def price
    # ActiveRecord provides has_attribute? so this will not raise if column missing
    if has_attribute?(:price)
      v = self[:price]
      return v.present? ? v.to_d : (product&.price.to_d if product&.price)
    else
      # Column doesn't exist in older DBs — use product price
      return product&.price.to_d if product&.respond_to?(:price) && product.price.present?
    end
    0.to_d
  end

  def line_subtotal
    (price.to_d * quantity.to_i).round(2)
  end

  private

  def set_price_if_missing
    # only set price on create if product price available and price not provided
    if has_attribute?(:price) && self[:price].blank? && product&.respond_to?(:price)
      self.price = product.price
    end
  end
end