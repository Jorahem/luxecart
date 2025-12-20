class CartItemsController < ApplicationController
  before_action :set_cart

  def create
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i > 0 ? params[:quantity].to_i : 1
    
    if product.stock_quantity >= quantity
      @cart.add_product(product, quantity)
      redirect_to cart_path, notice: 'Product added to cart successfully.'
    else
      redirect_to product_path(product), alert: 'Not enough stock available.'
    end
  end

  def update
    @cart.update_quantity(params[:id], params[:quantity].to_i)
    redirect_to cart_path, notice: 'Cart updated successfully.'
  end

  def destroy
    product = Product.find(params[:id])
    @cart.remove_product(product)
    redirect_to cart_path, notice: 'Product removed from cart.'
  end

  private

  def set_cart
    @cart = current_cart
  end
end
