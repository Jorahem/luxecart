class CartsController < ApplicationController
  before_action :set_cart
  before_action :set_cart_item, only: [:remove_item, :update_item]

  # GET /cart
  def show
    # Ensure @cart_items is never nil for the view
    @cart_items = @cart.cart_items.includes(:product) || []
    respond_to do |format|
      format.html
      format.json do
        render json: @cart.as_json(
          include: { cart_items: { include: :product } },
          methods: :total_price
        )
      end
    end
  end

  # POST /cart/add_item
  def add_item
    product = Product.find(params.require(:product_id))
    quantity = [params[:quantity].to_i, 1].max

    begin
      ActiveRecord::Base.transaction do
        # lock cart_items rows for concurrency safety
        item = @cart.cart_items.lock.find_by(product_id: product.id)

        if item
          item.increment!(:quantity, quantity)
        else
          attrs = build_cart_item_attributes(product, quantity)
          @cart.cart_items.create!(attrs)
        end
      end

      respond_to do |format|
        format.html { redirect_to cart_path, notice: "#{product.name} added to cart" }
        format.json do
          render json: {
            success: true,
            message: "#{product.name} added",
            cart: @cart.reload.as_json(include: { cart_items: { include: :product } })
          }, status: :created
        end
      end
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html { redirect_back fallback_location: products_path, alert: "Product not found" }
        format.json { render json: { error: "Product not found" }, status: :not_found }
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format|
        format.html { redirect_back fallback_location: products_path, alert: e.record.errors.full_messages.to_sentence }
        format.json { render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity }
      end
    rescue StandardError => e
      # Log full backtrace to development.log / server console for debugging
      Rails.logger.error "Error in CartsController#add_item: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}"

      respond_to do |format|
        format.html { redirect_back fallback_location: products_path, alert: "Failed to add to cart: #{e.message}" }
        format.json { render json: { error: "Failed to add to cart: #{e.message}" }, status: :internal_server_error }
      end
    end
  end

  # PATCH /cart/items/:id
  def update_item
    new_qty = [params[:quantity].to_i, 1].max
    if @cart_item.update(quantity: new_qty)
      respond_to do |format|
        format.html { redirect_to cart_path, notice: "Quantity updated" }
        format.json { render json: { success: true, cart_item: @cart_item }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to cart_path, alert: @cart_item.errors.full_messages.to_sentence }
        format.json { render json: { errors: @cart_item.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cart/remove_item/:id
  def remove_item
    if @cart_item
      @cart_item.destroy
      respond_to do |format|
        format.html { redirect_to cart_path, notice: "Item removed" }
        format.json { render json: { success: true }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to cart_path, alert: "Item not found" }
        format.json { render json: { error: "Item not found" }, status: :not_found }
      end
    end
  end

  private

  # Build a safe attributes hash for CartItem create!
  # Only includes keys/columns that actually exist on CartItem to avoid UnknownAttributeError.
  def build_cart_item_attributes(product, quantity)
    attrs = { product: product, quantity: quantity }

    # Determine cents value if possible
    cents = nil
    if product.respond_to?(:price_cents) && product.price_cents.present?
      cents = product.price_cents.to_i
    elsif product.respond_to?(:unit_price_cents) && product.unit_price_cents.present?
      cents = product.unit_price_cents.to_i
    elsif product.respond_to?(:price) && product.price.present?
      # convert decimal to integer cents safely
      begin
        cents = (BigDecimal(product.price.to_s) * 100).to_i
      rescue
        cents = nil
      end
    elsif product.respond_to?(:unit_price_decimal) && product.unit_price_decimal.present?
      begin
        cents = (BigDecimal(product.unit_price_decimal.to_s) * 100).to_i
      rescue
        cents = nil
      end
    end

    # Determine decimal price if possible
    decimal_price = nil
    if product.respond_to?(:price) && product.price.present?
      decimal_price = product.price
    elsif product.respond_to?(:unit_price_decimal) && product.unit_price_decimal.present?
      decimal_price = product.unit_price_decimal
    elsif cents
      # convert cents back to decimal if needed
      begin
        decimal_price = BigDecimal(cents) / 100
      rescue
        decimal_price = nil
      end
    end

    # Only include keys that CartItem actually has
    cart_item_columns = CartItem.column_names

    if cart_item_columns.include?('unit_price_cents') && cents
      attrs[:unit_price_cents] = cents
    end

    # Prefer unit_price (decimal) name if present, otherwise unit_price_decimal
    if cart_item_columns.include?('unit_price') && decimal_price
      attrs[:unit_price] = decimal_price
    elsif cart_item_columns.include?('unit_price_decimal') && decimal_price
      attrs[:unit_price_decimal] = decimal_price
    end

    # If your CartItem has a money-rails style "price_cents" column, support that too
    if cart_item_columns.include?('price_cents') && cents
      attrs[:price_cents] = cents
    end

    attrs
  end

  def set_cart
    if defined?(current_user) && respond_to?(:user_signed_in?) && user_signed_in?
      @cart = current_user.cart || current_user.create_cart
      session[:cart_id] = @cart.id
      return
    end

    if session[:cart_id].present?
      @cart = Cart.find_by(id: session[:cart_id]) || Cart.create.tap { |c| session[:cart_id] = c.id }
    else
      @cart = Cart.create
      session[:cart_id] = @cart.id
    end
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find_by(id: params[:id])
    unless @cart_item
      respond_to do |format|
        format.html { redirect_to cart_path, alert: "Item not found" }
        format.json { render json: { error: "Item not found" }, status: :not_found }
      end
    end
  end
end