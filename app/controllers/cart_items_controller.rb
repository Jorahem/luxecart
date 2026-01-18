# app/controllers/cart_items_controller.rb
class CartItemsController < ApplicationController
  # Allow anonymous users to add to cart (adjust if you require login)
  skip_before_action :authenticate_user!, only: [:create], raise: false if respond_to?(:skip_before_action)

  # POST /cart/add_item
  def create
    product = Product.find_by(id: params[:product_id])
    unless product
      render json: { error: 'Product not found' }, status: :not_found and return
    end

    session[:cart] ||= {}
    key = product.id.to_s
    session[:cart][key] = session[:cart].fetch(key, 0).to_i + 1

    cart_count = session[:cart].values.map(&:to_i).sum
    Rails.logger.debug "[CartItemsController#create] session[:cart]=#{session[:cart].inspect}"

    render json: { cart_count: cart_count, cart: session[:cart] }, status: :ok
  rescue => e
    Rails.logger.error "[CartItemsController#create] #{e.class}: #{e.message}\n#{e.backtrace.first(8).join("\n")}"
    render json: { error: 'Could not add to cart' }, status: :internal_server_error
  end
end