class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  # GET /products
  def index
    products = Product.all

    # Eager load associations used in view (adjust as needed)
    products = products.includes(:categories) if Product.reflect_on_association(:categories)

    # Category filter
    @selected_category = nil
    if params[:category].present?
      cat_param = params[:category].to_s.strip

      if cat_param.match?(/\A\d+\z/)
        @selected_category = Category.find_by(id: cat_param.to_i)
      else
        if Category.column_names.include?('slug')
          @selected_category = Category.find_by(slug: cat_param) rescue nil
        end
        @selected_category ||= Category.where('lower(name) = ?', cat_param.downcase).first if Category.column_names.include?('name')
      end

      if @selected_category
        if Product.reflect_on_association(:categories)
          products = products.joins(:categories).where(categories: { id: @selected_category.id }).distinct
        else
          products = products.where(category_id: @selected_category.id) if Product.column_names.include?('category_id')
        end
      else
        products = products.none
      end
    end

    # Search
    if params[:q].present?
      q = params[:q].strip
      products = products.where("name ILIKE :s OR description ILIKE :s", s: "%#{q}%")
    end

    # Sorting
    case params[:sort]
    when 'price_asc'
      products = products.order(price: :asc)
    when 'price_desc'
      products = products.order(price: :desc)
    when 'newest'
      products = products.order(created_at: :desc)
    else
      if Product.column_names.include?('featured')
        products = products.order(featured: :desc, created_at: :desc)
      else
        products = products.order(created_at: :desc)
      end
    end

    # Pagination: Kaminari if present
    if defined?(Kaminari)
      @products = products.page(params[:page]).per(12)
    else
      @products = products.limit(100)
    end

    # Provide categories list for sidebar (limit to first 20)
    @categories = Category.limit(20) if defined?(Category)
  end

  # GET /products/:id or /products/:slug
  def show
    unless @product
      respond_to do |format|
        format.html { redirect_to products_path, alert: "Product not found" }
        format.json { render json: { error: "Product not found" }, status: :not_found }
      end
      return
    end

    # If you ever need JSON for the product detail page:
    respond_to do |format|
      format.html # renders app/views/products/show.html.erb
      format.json { render json: @product }
    end
  end

  private

  # Tries id, slug, permalink, handle, FriendlyId, and name fallback
  def set_product
    key = params[:id].to_s
    @product = nil

    # 1) Try numeric id
    if key =~ /\A\d+\z/
      @product = Product.find_by(id: key)
      return if @product
    end

    # 2) Try common slug/permalink/handle columns if they exist
    %w[slug permalink handle].each do |col|
      next unless Product.column_names.include?(col)
      begin
        @product = Product.find_by(col => key)
        return if @product
      rescue StandardError
        # ignore and continue
      end
    end

    # 3) Try FriendlyId if it's configured for Product
    if Product.respond_to?(:friendly)
      begin
        @product = Product.friendly.find(key) rescue nil
        return if @product
      rescue StandardError
        # ignore and continue
      end
    end

    # 4) Try matching by name (case-insensitive, replace dashes)
    if Product.column_names.include?('name')
      param_name = key.tr('-', ' ')
      @product = Product.where('lower(name) = ?', param_name.downcase).first
      return if @product
    end

    # 5) As a last attempt, try slug-like column with parameterized name
    %w[slug permalink handle].each do |col|
      next unless Product.column_names.include?(col)
      param_candidate = params[:id].to_s.parameterize
      @product = Product.where("#{col} = ?", param_candidate).first
      return if @product
    end

    # If nothing found, @product remains nil and show will redirect.
  end
end