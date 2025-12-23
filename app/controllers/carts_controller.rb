class CartsController < ApplicationController
  before_action :set_cart

  def show
    @cart_items = @cart.cart_items.includes(:product)
  end

  def add_item
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i > 0 ? params[:quantity].to_i : 1
    
    # Check stock availability
    if product.stock_quantity < quantity
      redirect_to product_path(product), alert: "Only #{product.stock_quantity} items available in stock."
      return
    end
    
    @cart.add_product(product, quantity)
    redirect_to cart_path, notice: 'Product added to cart successfully.'
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: 'Product not found.'
  end

  def update_item
    @cart.update_quantity(params[:product_id], params[:quantity].to_i)
    redirect_to cart_path, notice: 'Cart updated successfully.'
  end

  def remove_item
    product = Product.find(params[:product_id])
    @cart.remove_product(product)
    redirect_to cart_path, notice: 'Product removed from cart.'
  end

  def clear
    @cart.clear
    redirect_to cart_path, notice: 'Cart cleared successfully.'
  end

  private

  def set_cart
    @cart = current_cart
  end
end
