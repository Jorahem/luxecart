class CheckoutController < ApplicationController
  before_action :require_login
  before_action :set_cart
  before_action :ensure_cart_not_empty, only: [:new, :create]

  def new
    @order = Order.new
  end

  def create
    @order = current_user.orders.build(order_params)
    
    # Build order items from cart
    @cart.cart_items.each do |cart_item|
      @order.order_items.build(
        product: cart_item.product,
        quantity: cart_item.quantity,
        unit_price: cart_item.product.price,
        total_price: cart_item.product.price * cart_item.quantity,
        product_name: cart_item.product.name,
        product_sku: cart_item.product.sku
      )
    end

    # Set payment method to cash on delivery by default
    @order.payment_method ||= 'cash_on_delivery'
    # Mark COD orders as paid since payment will be collected on delivery
    @order.payment_status = :paid if @order.payment_method == 'cash_on_delivery'

    if @order.save
      @cart.clear
      redirect_to checkout_confirmation_path(@order), notice: 'Order placed successfully!'
    else
      render :new
    end
  end

  def confirmation
    @order = current_user.orders.find(params[:id])
    @order_items = @order.order_items.includes(:product)
  end

  private

  def set_cart
    @cart = current_cart
  end

  def ensure_cart_not_empty
    if @cart.empty?
      redirect_to cart_path, alert: 'Your cart is empty.'
    end
  end

  def order_params
    params.require(:order).permit(:payment_method, :notes)
  end
end