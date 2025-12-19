class Wishlist < ApplicationRecord
  belongs_to :user
  has_many :wishlist_items, dependent: :destroy
  has_many :products, through: :wishlist_items

  def add_product(product)
    wishlist_items.find_or_create_by(product: product)
  end

  def remove_product(product)
    wishlist_items.find_by(product: product)&.destroy
  end

  def contains?(product)
    products.include?(product)
  end
end