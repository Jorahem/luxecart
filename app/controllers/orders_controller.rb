class OrdersController < ApplicationController
  before_action :authenticate_user!, except: [:success]
  before_action :load_session_cart
  before_action :ensure_cart_not_empty, only: [:new, :create]

  # Show checkout/order summary page
  def new
    @order = Order.new
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

      @summary_items << {
        product:    product,
        quantity:   quantity,
        unit_price: unit_price
      }
    end
  end

  # List current user's orders
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  # Show an individual order (customer can only view their own)
  def show
    @order = current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: "Order not found."
  end

  # Customer marks an order as received (final tracking step)
  # Requires route: patch /orders/:id/mark_received
  def mark_received
    @order = current_user.orders.find(params[:id])

    can_mark =
      if @order.respond_to?(:can_mark_received?)
        @order.can_mark_received?
      else
        @order.status.to_s == "delivered"
      end

    if can_mark
      @order.update!(status: :received)
      redirect_to order_path(@order), notice: "Thanks! Order marked as received."
    else
      redirect_to order_path(@order), alert: "This order cannot be marked as received yet."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: "Order not found."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to order_path(@order), alert: e.message
  end

  # Create an order from the session cart
  def create
    @order = current_user.orders.build(order_params)

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

      @order.order_items.build(
        product_id:   product.id,
        quantity:     quantity,
        unit_price:   unit_price,
        total_price:  line_total,
        product_name: product.name,
        product_sku:  (product.respond_to?(:sku) ? product.sku : nil)
      )
    end

    if @order.order_items.empty?
      redirect_to cart_path, alert: "Your cart is empty." and return
    end

    shipping_cost = 0.to_d
    tax           = 0.to_d
    total         = subtotal + shipping_cost + tax

    @order.subtotal       = subtotal
    @order.shipping_cost  = shipping_cost
    @order.tax            = tax
    @order.total_price    = total
    @order.payment_method = params.dig(:order, :payment_method)

    # Customer must not set status; always start pending unless already set by system
    if @order.respond_to?(:status) && @order.status.blank?
      @order.status = :pending
    end

    Order.transaction do
      @order.save!
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

  def load_session_cart
    @session_cart = session[:cart] || {}
  end

  def ensure_cart_not_empty
    redirect_to cart_path, alert: "Your cart is empty." if @session_cart.blank?
  end

  # IMPORTANT: do NOT permit :status or tracking fields here (admin-only)
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