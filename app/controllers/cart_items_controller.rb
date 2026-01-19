# app/controllers/cart_items_controller.rb
class CartItemsController < ApplicationController
  # NOW: require user to be logged in for create
  before_action :authenticate_user!

  # POST /cart/add_item
  def create
    product = Product.find_by(id: params[:product_id])
    unless product
      respond_to do |format|
        format.json { render json: { error: 'Product not found' }, status: :not_found }
        format.html { redirect_back fallback_location: products_path, alert: 'Product not found' }
      end
      return
    end

    session[:cart] ||= {}
    key = product.id.to_s
    session[:cart][key] = session[:cart].fetch(key, 0).to_i + 1

    cart_count = session[:cart].values.map(&:to_i).sum
    Rails.logger.debug "[CartItemsController#create] session[:cart]=#{session[:cart].inspect}"

    respond_to do |format|
      format.json do
        render json: {
          message: 'Added to cart',
          cart_count: cart_count,
          cart: session[:cart]
        }, status: :ok
      end

      format.html do
        redirect_back fallback_location: products_path, notice: 'Added to cart'
      end
    end
  rescue => e
    Rails.logger.error "[CartItemsController#create] #{e.class}: #{e.message}\n#{e.backtrace.first(8).join("\n")}"

    respond_to do |format|
      format.json { render json: { error: 'Could not add to cart' }, status: :internal_server_error }
      format.html { redirect_back fallback_location: products_path, alert: 'Could not add to cart' }
    end
  end
end