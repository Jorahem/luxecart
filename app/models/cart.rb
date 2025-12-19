class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def add_product(product, quantity = 1)
    current_item = cart_items.find_by(product_id: product.id)
    if current_item
      current_item.quantity += quantity
      current_item.save
    else
      cart_items.create(product: product, quantity: quantity)
    end
  end

  def remove_product(product)
    cart_items.find_by(product_id: product.id)&.destroy
  end

  def update_quantity(product_id, quantity)
    item = cart_items.find_by(product_id: product_id)
    if item
      quantity > 0 ? item.update(quantity: quantity) : item.destroy
    end
  end

  def total_items
    cart_items.sum(:quantity)
  end

  def subtotal
    cart_items.includes(:product).sum { |item| item.product.price * item.quantity }
  end

  def clear
    cart_items.destroy_all
  end

  def empty?
    cart_items.empty?
  end
end