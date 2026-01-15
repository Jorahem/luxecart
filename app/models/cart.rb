class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy

  # Add or update a cart item, returns the CartItem
  def add_item!(product, quantity = 1, price: nil)
    price ||= product.try(:price) || 0
    item = cart_items.find_by(product_id: product.id)
    if item
      item.quantity += quantity.to_i
      item.price = price
      item.save!
    else
      item = cart_items.create!(product: product, quantity: quantity.to_i, price: price)
    end
    item
  end

  def update_item!(item_id, quantity)
    item = cart_items.find(item_id)
    item.update!(quantity: quantity.to_i)
    item
  end

  def remove_item!(item_id)
    cart_items.find(item_id).destroy
  end

  def clear!
    cart_items.destroy_all
  end

  def subtotal
    cart_items.to_a.sum { |ci| (ci.price.to_d * ci.quantity) }
  end

  def total_quantity
    cart_items.sum(:quantity)
  end

  # flat shipping for example
  def shipping_cost
    return 0 if subtotal.zero?
    BigDecimal("9.99")
  end

  def tax(rate = 0.10)
    (subtotal * BigDecimal(rate.to_s)).round(2)
  end

  def total
    (subtotal + shipping_cost + tax).round(2)
  end
end