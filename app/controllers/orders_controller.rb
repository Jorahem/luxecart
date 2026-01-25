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

  # Show an individual order (fixes NoMethodError on orders/show)
  def show
    @order = Order.find(params[:id])
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