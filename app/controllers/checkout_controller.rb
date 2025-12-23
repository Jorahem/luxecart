class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart
  before_action :ensure_cart_not_empty

  def new
    @order = current_user.orders.build
    @addresses = current_user.addresses
    @default_address = current_user.addresses.find_by(is_default: true)
  end

  def create
    ActiveRecord::Base.transaction do
      # Validate stock before creating order
      @cart.cart_items.each do |cart_item|
        if cart_item.product.stock_quantity < cart_item.quantity
          raise "Insufficient stock for #{cart_item.product.name}"
        end
      end
      
      @order = current_user.orders.build(order_params)
      
      @cart.cart_items.each do |cart_item|
        @order.order_items.build(
          product: cart_item.product,
          quantity: cart_item.quantity,
          unit_price: cart_item.product.price
        )
      end

      if params[:coupon_code].present?
        coupon = Coupon.find_by(code: params[:coupon_code])
        if coupon&.active?
          @order.coupon_code = coupon.code
          @order.discount_amount = coupon.calculate_discount(@order.subtotal)
        end
      end

      if @order.save
        # Deduct stock
        @cart.cart_items.each do |cart_item|
          cart_item.product.decrement!(:stock_quantity, cart_item.quantity)
        end
        
        if process_payment(@order)
          @order.update!(payment_status: :paid, status: :processing)
          @cart.clear
          redirect_to order_path(@order), notice: 'Order placed successfully!'
        else
          raise "Payment processing failed"
        end
      else
        @addresses = current_user.addresses
        render :new
      end
    end
  rescue => e
    @order&.destroy
    redirect_to new_checkout_path, alert: "Order failed: #{e.message}"
  end

  private

  def set_cart
    @cart = current_cart
  end

  def ensure_cart_not_empty
    redirect_to cart_path, alert: 'Your cart is empty.' if @cart.empty?
  end

  def order_params
    params.require(:order).permit(:payment_method, :notes)
  end

  def process_payment(order)
    if order.payment_method == 'stripe'
      begin
        payment_intent = Stripe::PaymentIntent.create(
          amount: (order.total_price * 100).to_i,
          currency: 'usd',
          metadata: { order_id: order.id }
        )
        order.update(stripe_payment_intent_id: payment_intent.id)
        true
      rescue Stripe::CardError
        false
      end
    else
      true
    end
  end
end