class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy

  # Safely add an item to the cart.
  # - Increments quantity if the product already exists in the cart.
  # - When creating a new CartItem, writes to one of the existing price columns
  #   (unit_price_decimal, unit_price_cents, or price_cents) instead of a non-existent
  #   :price attribute.
  def add_item!(product, quantity = 1)
    quantity = [quantity.to_i, 1].max

    ActiveRecord::Base.transaction do
      # lock existing rows for concurrency safety
      item = cart_items.lock.find_by(product_id: product.id)

      if item
        item.increment!(:quantity, quantity)
        return item
      end

      attrs = { product: product, quantity: quantity }

      # Determine available price columns on CartItem
      cols = cart_items.klass.column_names

      # Prefer decimal column if present
      if cols.include?('unit_price_decimal')
        if product.respond_to?(:price) && product.price.present?
          attrs[:unit_price_decimal] = product.price
        elsif product.respond_to?(:unit_price_decimal) && product.unit_price_decimal.present?
          attrs[:unit_price_decimal] = product.unit_price_decimal
        end
      end

      # Fallback to integer cents column
      if attrs[:unit_price_decimal].nil? && cols.include?('unit_price_cents')
        if product.respond_to?(:price_cents) && product.price_cents.present?
          attrs[:unit_price_cents] = product.price_cents.to_i
        elsif product.respond_to?(:unit_price_cents) && product.unit_price_cents.present?
          attrs[:unit_price_cents] = product.unit_price_cents.to_i
        elsif product.respond_to?(:price) && product.price.present?
          begin
            attrs[:unit_price_cents] = (BigDecimal(product.price.to_s) * 100).to_i
          rescue
            # ignore conversion errors; price will be left nil
          end
        end
      end

      # Support money-rails style column if present
      if attrs[:unit_price_decimal].nil? && attrs[:unit_price_cents].nil? && cols.include?('price_cents') && product.respond_to?(:price_cents)
        attrs[:price_cents] = product.price_cents.to_i
      end

      cart_items.create!(attrs)
    end
  end

  # Update a cart item's quantity (used by controllers)
  def update_item!(item_id, quantity)
    item = cart_items.find(item_id)
    item.update!(quantity: quantity.to_i)
    item
  end

  # Remove a cart item
  def remove_item!(item_id)
    cart_items.find(item_id).destroy
  end

  # Clear the cart
  def clear!
    cart_items.destroy_all
  end

  # Calculate subtotal/total amount for cart items.
  # Prefers unit_price_decimal when present, otherwise uses cents columns.
  def total_amount
    cart_items.includes(:product).sum do |item|
      if item.respond_to?(:unit_price_decimal) && item.unit_price_decimal.present?
        item.unit_price_decimal * item.quantity
      else
        cents = if item.respond_to?(:unit_price_cents)
                  (item.unit_price_cents || 0)
                elsif item.respond_to?(:price_cents)
                  (item.price_cents || 0)
                else
                  # fall back to CartItem#price (virtual accessor that may return product price)
                  (item.price.to_d * 100).to_i rescue 0
                end
        (cents / 100.0) * item.quantity
      end
    end
  end

  # For backwards-compatibility: many views expect `cart.subtotal`
  def subtotal
    total_amount
  end

  # Return total number of items in the cart (sum of quantities).
  def total_quantity
    cart_items.sum(:quantity).to_i
  end
  alias_method :total_items, :total_quantity

  # Flat shipping for example (adjust as needed)
  def shipping_cost
    return 0 if subtotal.zero?
    BigDecimal("9.99")
  end

  # Simple tax calculation (default 10%)
  def tax(rate = 0.10)
    (subtotal * BigDecimal(rate.to_s)).round(2)
  end

  # Grand total (subtotal + shipping + tax)
  def total
    (subtotal + shipping_cost + tax).round(2)
  end

  # Some controllers/views in the app may call `total_price` — provide an alias for compatibility.
  alias_method :total_price, :total_amount
end