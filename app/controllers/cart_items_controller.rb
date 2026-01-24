# app/controllers/cart_items_controller.rb
class CartItemsController < ApplicationController
  # Allow anonymous adds (session-based cart).
  # Ensure CSRF is enforced (do not disable) — front-end already sends X-CSRF-Token.

  # POST /cart/add_item
  def create
    # Accept common param names (product_id, productId, id)
    product_id_param = params[:product_id] || params[:productId] || params[:id]
    product_id = product_id_param.to_s.strip

    product = Product.find_by(id: product_id)
    unless product
      respond_to do |format|
        format.json { render json: { error: 'Product not found', product_id: product_id }, status: :not_found }
        format.html { redirect_back fallback_location: products_path, alert: 'Product not found' }
      end
      return
    end

    # Quantity support (default to 1 if not provided / invalid)
    qty = (params[:quantity].to_i > 0) ? params[:quantity].to_i : 1

    session[:cart] ||= {}
    key = product.id.to_s
    session[:cart][key] = session[:cart].fetch(key, 0).to_i + qty

    cart_count = session[:cart].values.map(&:to_i).sum

    # Build a small snapshot of the added product so client can verify what was added.
    added_product = {
      id: product.id,
      name: product.try(:name),
      price: product.try(:price),
      image: product_image_url(product)
    }

    Rails.logger.debug "[CartItemsController#create] product_id=#{product.id} qty=#{qty} session[:cart]=#{session[:cart].inspect}"

    respond_to do |format|
      format.json do
        render json: {
          message: 'Added to cart',
          cart_count: cart_count,
          cart: session[:cart],
          added_product: added_product
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

  private

  # Attempts to find a suitable image URL for the product.
  # Tries, in order:
  #  - first product_images.first.image (ActiveStorage) or .image_url
  #  - product.image_url attribute
  #  - product.image (ActiveStorage) via url_for
  def product_image_url(product)
    url = nil

    # product_images (if present)
    if product.respond_to?(:product_images) && product.product_images.any?
      begin
        pi = product.product_images.first
        if pi.respond_to?(:image_url) && pi.image_url.present?
          url = pi.image_url
        elsif pi.respond_to?(:image) && pi.image.respond_to?(:attached?) && pi.image.attached?
          url = url_for(pi.image) rescue nil
        end
      rescue => _e
        url = nil
      end
    end

    # direct image_url attribute
    if url.blank? && product.respond_to?(:image_url) && product.image_url.present?
      url = product.image_url
    end

    # ActiveStorage attachment on product
    if url.blank? && product.respond_to?(:image) && product.image.respond_to?(:attached?) && product.image.attached?
      url = url_for(product.image) rescue nil
    end

    url
  rescue
    nil
  end
end