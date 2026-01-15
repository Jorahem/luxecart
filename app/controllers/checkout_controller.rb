class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart
  before_action :ensure_cart_not_empty

  # Show checkout form. If the user was redirected here after saving an address,
  # params[:selected_address_id] will be present and we prefer that address for selection.
  def new
    @order = current_user.orders.build
    @addresses = current_user.addresses

    # Prefer the address explicitly selected (e.g. returned from AddressesController#create),
    # otherwise fall back to user's default address (if any).
    if params[:selected_address_id].present?
      @default_address = @addresses.find_by(id: params[:selected_address_id])
    end
    @default_address ||= @addresses.find_by(is_default: true)

    # expose selected_address_id to the view (useful for hidden field)
    @selected_address_id = params[:selected_address_id]
  end

  # Create an order from the current user's cart items and chosen options.
  # Note: coupon handling was intentionally removed per your request.
  def create
    @order = current_user.orders.build(order_params)
    @selected_address_id = params[:selected_address_id] # available during the create action

    # Build order items from cart items. Prefer any stored per-item price if present,
    # otherwise fall back to product.price.
    @cart.cart_items.each do |cart_item|
      unit_price =
        if cart_item.respond_to?(:read_attribute) && cart_item.has_attribute?('unit_price_decimal') && cart_item.read_attribute('unit_price_decimal').present?
          BigDecimal(cart_item.read_attribute('unit_price_decimal').to_s)
        elsif cart_item.respond_to?(:read_attribute) && cart_item.has_attribute?('unit_price') && cart_item.read_attribute('unit_price').present?
          BigDecimal(cart_item.read_attribute('unit_price').to_s)
        elsif cart_item.respond_to?(:read_attribute) && cart_item.has_attribute?('unit_price_cents') && cart_item.read_attribute('unit_price_cents').present?
          BigDecimal(cart_item.read_attribute('unit_price_cents').to_s) / 100
        elsif cart_item.product && cart_item.product.respond_to?(:price) && cart_item.product.price.present?
          BigDecimal(cart_item.product.price.to_s)
        else
          BigDecimal("0")
        end

      @order.order_items.build(
        product: cart_item.product,
        quantity: cart_item.quantity,
        unit_price: unit_price
      )
    end

    if @order.save
      if process_payment(@order)
        @order.update(payment_status: :paid, status: :processing)
        @cart.clear
        redirect_to order_path(@order), notice: 'Order placed successfully!'
      else
        @order.update(payment_status: :failed)
        redirect_to new_checkout_path, alert: 'Payment failed. Please try again.'
      end
    else
      # Re-load addresses so the form can render properly
      @addresses = current_user.addresses
      render :new
    end
  end

  private

  def set_cart
    @cart = current_cart
  end

  def ensure_cart_not_empty
    redirect_to cart_path, alert: 'Your cart is empty.' if @cart.empty?
  end

  # Only permit the fields the Order model expects.
  # Note: selected_address_id is not an Order attribute here (we don't persist it to orders),
  # so we read it from params directly when needed.
  def order_params
    params.require(:order).permit(:payment_method, :notes)
  end

  # Handle payment processing. For Stripe, create a PaymentIntent and store its id on the order.
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
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe error while creating payment intent: #{e.class} - #{e.message}"
        false
      end
    else
      # Non-stripe payments are treated as successful (you can expand this branch later)
      true
    end
  end
end