class CartsController < ApplicationController
  # Allow anonymous access for cart actions (remove if you want auth)
  skip_before_action :authenticate_user!,
                     only: %i[show summary update_item remove_item],
                     raise: false if respond_to?(:skip_before_action)

  # GET /cart
  def show
    cart = session[:cart] || {}
    Rails.logger.debug "[CartsController#show] session[:cart]=#{cart.inspect}"

    product_ids = cart.keys.map(&:to_i)
    products_by_id = Product.where(id: product_ids).index_by(&:id)

    @items = cart.map do |pid_str, qty|
      pid = pid_str.to_i
      product = products_by_id[pid]

      if product
        { product: product, quantity: qty.to_i }
      else
        { product: nil, product_id: pid, quantity: qty.to_i }
      end
    end

    # Order tracking / history only for signed-in users
    @last_order = nil
    @recent_orders = []

    if respond_to?(:user_signed_in?) && user_signed_in?
      @last_order = current_user.orders.order(created_at: :desc).first

      @recent_orders =
        current_user
          .orders
          .includes(order_items: :product)
          .order(created_at: :desc)
          .limit(5)
    end
  end

  # PATCH /cart/update_item/:id
  # Params: quantity
  def update_item
    pid = params[:id].to_s
    qty = params[:quantity].to_i

    session[:cart] ||= {}

    if qty.positive?
      session[:cart][pid] = qty
    else
      session[:cart].delete(pid)
    end

    cart_count = session[:cart].values.map(&:to_i).sum
    Rails.logger.debug "[CartsController#update_item] pid=#{pid} qty=#{qty} session[:cart]=#{session[:cart].inspect}"

    render json: { cart_count: cart_count, cart: session[:cart] }, status: :ok
  rescue => e
    Rails.logger.error "[CartsController#update_item] #{e.class}: #{e.message}\n#{e.backtrace.first(8).join("\n")}"
    render json: { error: "Could not update cart" }, status: :internal_server_error
  end

  # DELETE /cart/remove_item/:id
  def remove_item
    pid = params[:id].to_s
    session[:cart] ||= {}
    session[:cart].delete(pid)

    cart_count = session[:cart].values.map(&:to_i).sum
    Rails.logger.debug "[CartsController#remove_item] pid=#{pid} session[:cart]=#{session[:cart].inspect}"

    render json: { cart_count: cart_count, cart: session[:cart] }, status: :ok
  rescue => e
    Rails.logger.error "[CartsController#remove_item] #{e.class}: #{e.message}\n#{e.backtrace.first(8).join("\n")}"
    render json: { error: "Could not remove item" }, status: :internal_server_error
  end

  # GET /cart/summary (JSON)
  def summary
    cart = session[:cart] || {}
    render json: { cart: cart, cart_count: cart.values.map(&:to_i).sum }, status: :ok
  end
end