class CartsController < ApplicationController
  before_action :set_cart

  # GET /cart
  def show
    @cart_items = @cart.cart_items.includes(:product)
  end

  # POST /cart/add_item
  def add_item
    product = Product.find(params[:product_id])
    quantity = (params[:quantity] || 1).to_i
    quantity = 1 if quantity < 1

    item = @cart.cart_items.find_by(product_id: product.id)

    if item
      item.quantity += quantity
      item.save!
    else
      @cart.cart_items.create!(product: product, quantity: quantity,
                               unit_price_cents: (product.respond_to?(:price_cents) ? product.price_cents : nil),
                               unit_price_decimal: (product.respond_to?(:price) ? product.price : nil))
    end

    redirect_to cart_path, notice: "#{product.name} added to cart"
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: products_path, alert: "Product not found"
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: products_path, alert: e.record.errors.full_messages.to_sentence
  end

  # DELETE /cart/remove_item/:id
  def remove_item
    item = @cart.cart_items.find_by(id: params[:id])
    if item
      item.destroy
      redirect_to cart_path, notice: "Item removed"
    else
      redirect_to cart_path, alert: "Item not found"
    end
  end

  private

  # ensure @cart is always set: prefer current_user.cart, fall back to session cart
  def set_cart
    if user_signed_in?
      @cart = current_user.cart || current_user.create_cart
      session[:cart_id] = @cart.id
      return
    end

    if session[:cart_id].present?
      @cart = Cart.find_by(id: session[:cart_id]) || Cart.create.tap { |c| session[:cart_id] = c.id }
    else
      @cart = Cart.create
      session[:cart_id] = @cart.id
    end
  end
end