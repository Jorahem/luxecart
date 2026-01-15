class OrdersController < ApplicationController
  before_action :set_cart

  def new
    redirect_to cart_path, alert: 'Your cart is empty.' if @cart.cart_items.empty?
    @order = Order.new
  end

  def create
    if @cart.cart_items.empty?
      redirect_to cart_path, alert: 'Your cart is empty.' and return
    end

    @order = current_user ? current_user.orders.build(order_params) : Order.new(order_params)
    # compute totals server-side
    @order.subtotal = @cart.subtotal
    @order.shipping_cost = @cart.shipping_cost
    @order.tax = @cart.tax
    @order.total_price = @cart.total
    @order.payment_method = params[:order][:payment_method]

    Order.transaction do
      @order.save!
      @cart.cart_items.each do |ci|
        @order.order_items.create!(
          product_id: ci.product_id,
          quantity: ci.quantity,
          unit_price: ci.price,
          subtotal: (ci.price.to_d * ci.quantity)
        )
      end
      @cart.clear!
    end

    respond_to do |format|
      format.html { redirect_to order_success_path(@order), notice: 'Order placed successfully.' }
      format.json { render json: { success: true, order_id: @order.id } }
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  def success
    @order = Order.find(params[:id])
  end

  private

  def set_cart
    @cart = if session[:cart_id].present?
              Cart.find_by(id: session[:cart_id]) || Cart.create!
            else
              Cart.create!
            end
  end

  def order_params
    params.require(:order).permit(:full_name, :email, :phone, :shipping_street, :shipping_city, :shipping_postal_code, :shipping_state, :payment_method)
  end
end