class CheckoutController < ApplicationController
  # Require login to checkout
  before_action :authenticate_user!

  # Use the same cart as /cart (stored in session[:cart])
  before_action :load_session_cart
  before_action :ensure_cart_not_empty

  # GET /checkout
  def new
    @order = current_user.orders.build
    @addresses = current_user.addresses

    # Default address selection
    if params[:selected_address_id].present?
      @default_address = @addresses.find_by(id: params[:selected_address_id])
    end
    @default_address ||= @addresses.find_by(is_default: true)

    @selected_address_id = params[:selected_address_id]
  end

  # POST /checkout
  def create
    @order = current_user.orders.build(order_params)
    @selected_address_id = params[:selected_address_id]

    # Build order items from the session cart (@session_cart)
    @session_cart.each do |product_id_str, qty|
      product_id = product_id_str.to_i
      product = Product.find_by(id: product_id)
      next unless product

      quantity = qty.to_i
      next if quantity <= 0

      unit_price =
        if product.respond_to?(:price) && product.price.present?
          BigDecimal(product.price.to_s)
        else
          BigDecimal("0")
        end

      @order.order_items.build(
        product: product,
        quantity: quantity,
        unit_price: unit_price
      )
    end

    # If somehow no items were built, treat as empty cart
    if @order.order_items.empty?
      redirect_to cart_path, alert: "Your cart is empty." and return
    end

    if @order.save
      if process_payment(@order)
        @order.update(payment_status: :paid, status: :processing)
        # Clear the session cart (the one the cart page uses)
        session[:cart] = {}
        redirect_to order_path(@order), notice: "Order placed successfully!"
      else
        @order.update(payment_status: :failed)
        redirect_to new_checkout_path, alert: "Payment failed. Please try again."
      end
    else
      @addresses = current_user.addresses
      render :new
    end
  end

  private

  # Read the same cart structure used on /cart
  def load_session_cart
    @session_cart = session[:cart] || {}
  end

  # Decide if the cart is empty based on session[:cart]
  def ensure_cart_not_empty
    if @session_cart.blank?
      redirect_to cart_path, alert: "Your cart is empty."
    end
  end

  def order_params
    params.require(:order).permit(:payment_method, :notes)
  end

  def process_payment(order)
    if order.payment_method == "stripe"
      begin
        payment_intent = Stripe::PaymentIntent.create(
          amount: (order.total_price * 100).to_i,
          currency: "usd",
          metadata: { order_id: order.id }
        )
        order.update(stripe_payment_intent_id: payment_intent.id)
        true
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe error while creating payment intent: #{e.class} - #{e.message}"
        false
      end
    else
      # Non-stripe payments are treated as successful
      true
    end
  end
end