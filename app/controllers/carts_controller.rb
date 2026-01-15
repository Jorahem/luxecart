class CartsController < ApplicationController
  before_action :set_cart

  # GET /cart
  def show
    @cart_items = @cart.cart_items.includes(:product)
  end

  # POST /cart/add_item
  # params: product_id, quantity
  def add_item
    product = Product.find(params[:product_id])
    item = @cart.add_item!(product, params[:quantity] || 1, price: params[:price] || product.price)
    respond_to do |format|
      format.html { redirect_to cart_path, notice: 'Added to cart.' }
      format.json {
        render json: {
          success: true,
          item_id: item.id,
          html: render_to_string(partial: 'carts/cart_item', locals: { cart_item: item }, formats: [:html]),
          summary_html: render_to_string(partial: 'carts/summary', locals: { cart: @cart }, formats: [:html])
        }
      }
    end
  end

  # PATCH /cart/items/:id
  # params: quantity
  def update_item
    item = @cart.cart_items.find(params[:id])
    @cart.update_item!(item.id, params[:quantity].to_i)
    respond_to do |format|
      format.html { redirect_to cart_path }
      format.json {
        render json: {
          success: true,
          item_id: item.id,
          item_subtotal: view_context.number_to_currency(item.reload.subtotal),
          summary_html: render_to_string(partial: 'carts/summary', locals: { cart: @cart }, formats: [:html])
        }
      }
    end
  end

  # DELETE /cart/items/:id
  def remove_item
    item = @cart.cart_items.find(params[:id])
    item.destroy
    respond_to do |format|
      format.html { redirect_to cart_path, notice: 'Item removed.' }
      format.json {
        render json: { success: true, item_id: item.id, summary_html: render_to_string(partial: 'carts/summary', locals: { cart: @cart }, formats: [:html]) }
      }
    end
  end

  private

  def set_cart
    if session[:cart_id].present?
      @cart = Cart.find_by(id: session[:cart_id])
    end
    if @cart.nil?
      @cart = Cart.create!(user: current_user) rescue Cart.create!
      session[:cart_id] = @cart.id
    end
  end
end