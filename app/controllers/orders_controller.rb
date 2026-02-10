class OrdersController < ApplicationController
  before_action :authenticate_user!, except: [:success]
  before_action :load_session_cart
  before_action :ensure_cart_not_empty, only: [:new, :create]

  # Show checkout/order summary page
  def new
    @order = Order.new

    # Build a simple list of summary items from the session cart
    @summary_items = []

    @session_cart.each do |product_id_str, qty|
      product_id = product_id_str.to_i
      product    = Product.find_by(id: product_id)
      next unless product

      quantity = qty.to_i
      next if quantity <= 0

      unit_price =
        if product.respond_to?(:price) && product.price.present?
          BigDecimal(product.price.to_s)
        else
          BigDecimal("0")
        end

      # Use plain hashes instead of OpenStruct
      @summary_items << {
        product:    product,
        quantity:   quantity,
        unit_price: unit_price
      }
    end
  end

  # List current user's orders (your routes include :index)
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  # Show an individual order
  def show
    @order = Order.find(params[:id])

    # Basic authorization: user can only view their own order
    if @order.user_id.present? && @order.user_id != current_user.id
      redirect_to root_path, alert: "Not authorized." and return
    end
  end

  # Customer marks an order as received (tracking final step)
  # Requires route: patch /orders/:id/mark_received
  def mark_received
    @order = Order.find(params[:id])

    if @order.user_id.present? && @order.user_id != current_user.id
      redirect_to root_path, alert: "Not authorized." and return
    end

    if @order.respond_to?(:can_mark_received?) ? @order.can_mark_received? : (@order.status.to_s == "delivered")
      @order.update!(status: :received)
      redirect_to order_path(@order), notice: "Thanks! Order marked as received."
    else
      redirect_to order_path(@order), alert: "This order cannot be marked as received yet."
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to order_path(@order), alert: e.message
  end

  # Create an order from the session cart
  def create
    # Build a new order for the current user (or guest)
    @order = current_user ? current_user.orders.build(order_params) : Order.new(order_params)

    # Compute totals from the session cart
    subtotal = 0.to_d

    @session_cart.each do |product_id_str, qty|
      product_id = product_id_str.to_i
      product    = Product.find_by(id: product_id)
      next unless product

      quantity = qty.to_i
      next if quantity <= 0

      unit_price =
        if product.respond_to?(:price) && product.price.present?
          BigDecimal(product.price.to_s)
        else
          BigDecimal("0")
        end

      line_total = unit_price * quantity
      subtotal  += line_total

      # Build order_item snapshots that match your previous schema
      @order.order_items.build(
        product_id:   product.id,
        quantity:     quantity,
        unit_price:   unit_price,
        total_price:  line_total,
        product_name: product.name,
        product_sku:  (product.respond_to?(:sku) ? product.sku : nil)
      )
    end

    # If nothing could be built, treat as empty cart
    if @order.order_items.empty?
      redirect_to cart_path, alert: "Your cart is empty." and return
    end

    # Compute shipping/tax/total (adjust as you like)
    shipping_cost = 0.to_d
    tax           = 0.to_d
    total         = subtotal + shipping_cost + tax

    @order.subtotal       = subtotal
    @order.shipping_cost  = shipping_cost
    @order.tax            = tax
    @order.total_price    = total
    @order.payment_method = params.dig(:order, :payment_method)

    # Make sure a new order starts in a valid tracking state
    # (Does not override status if already set somewhere else)
    @order.status ||= :pending if @order.respond_to?(:status) && @order.status.blank?

    Order.transaction do
      @order.save!
      # Clear **session** cart (what /cart uses)
      session[:cart] = {}
    end

    respond_to do |format|
      format.html { redirect_to order_path(@order), notice: "Order placed successfully." }
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

  # Read the same cart structure used in CartsController#show
  def load_session_cart
    @session_cart = session[:cart] || {}
  end

  def ensure_cart_not_empty
    if @session_cart.blank?
      redirect_to cart_path, alert: "Your cart is empty."
    end
  end

  def index
  @orders = current_user.orders.order(created_at: :desc)
end

  def order_params
    params.require(:order).permit(
      :shipping_full_name,
      :shipping_phone,
      :shipping_street,
      :shipping_city,
      :shipping_state,
      :shipping_postal_code,
      :payment_method
    )
  end
end