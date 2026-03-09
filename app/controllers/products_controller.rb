class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  # GET /products
  def index
    # Build a cache key that reflects filters & pagination
    cache_key = [
      "products:index",
      params[:category].presence || "all",
      params[:q].to_s.strip.presence || "no-q",
      params[:sort].presence || "default",
      (params[:page] || 1).to_i
    ].join(":")

    @products, @categories, @selected_category =
      Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
        products = Product.all

        # Eager load associations used in view (adjust as needed)
        products = products.includes(:categories) if Product.reflect_on_association(:categories)

        selected_category = nil

        # -----------------------------
        # SPECIAL SHOES SUB-CATEGORY LOGIC
        # -----------------------------
        category_param = params[:category].to_s.strip.downcase
        if %w[men-shoes women-shoes children-shoes].include?(category_param)
          shoes_category =
            if Product.reflect_on_association(:categories)
              Category.find_by('lower(name) = ?', 'shoes')
            else
              Category.find_by('lower(name) = ?', 'shoes')
            end

          if shoes_category
            # Filter base scope to Shoes category
            if Product.reflect_on_association(:categories)
              products = products.joins(:categories).where(categories: { id: shoes_category.id }).distinct
            else
              products = products.where(category_id: shoes_category.id) if Product.column_names.include?('category_id')
            end

            # Extra filter by product name using the prefix we used in seeds
            case category_param
            when 'men-shoes'
              products = products.where("products.name ILIKE :m OR products.name ILIKE :m2",
                                        m: "Men%'",
                                        m2: "%Men's%")
            when 'women-shoes'
              products = products.where("products.name ILIKE :w OR products.name ILIKE :w2",
                                        w: "Women%'",
                                        w2: "%Women's%")
            when 'children-shoes'
              # our seeds use "Kids ..." for children shoes
              products = products.where("products.name ILIKE ?", "Kids%")
            end

            selected_category = shoes_category
          else
            products = products.none
          end
        else
          # -----------------------------
          # NORMAL CATEGORY FILTER (your original logic)
          # -----------------------------
          selected_category = nil
          if params[:category].present?
            cat_param = params[:category].to_s.strip

            if cat_param.match?(/\A\d+\z/)
              selected_category = Category.find_by(id: cat_param.to_i)
            else
              if Category.column_names.include?('slug')
                selected_category = Category.find_by(slug: cat_param) rescue nil
              end
              if selected_category.nil? && Category.column_names.include?('name')
                selected_category ||= Category.where('lower(name) = ?', cat_param.downcase).first
              end
            end

            if selected_category
              if Product.reflect_on_association(:categories)
                products = products.joins(:categories).where(categories: { id: selected_category.id }).distinct
              else
                products = products.where(category_id: selected_category.id) if Product.column_names.include?('category_id')
              end
            else
              products = products.none
            end
          end
        end

        # -----------------------------
        # Search (unchanged)
        # -----------------------------
        if params[:q].present?
          q = params[:q].strip
          products = products.where("name ILIKE :s OR description ILIKE :s", s: "%#{q}%")
        end

        # -----------------------------
        # Sorting (unchanged)
        # -----------------------------
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

        # -----------------------------
        # Pagination (unchanged)
        # -----------------------------
        if defined?(Kaminari)
          products = products.page(params[:page]).per(12)
        else
          products = products.limit(100)
        end

        categories = Category.limit(20) if defined?(Category)

        [products, categories, selected_category]
      end
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

    respond_to do |format|
      format.html
      format.json { render json: @product }
    end
  end

  private

  # Tries id, slug, permalink, handle, FriendlyId, and name fallback
  def set_product
    key = params[:id].to_s

    # Cache the product lookup as well to protect DB when a product is hot
    cache_key = "products:show:lookup:#{key}"

    @product = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      found = nil

      # 1) Try numeric id
      if key =~ /\A\d+\z/
        found = Product.find_by(id: key)
        return found if found
      end

      # 2) Try common slug/permalink/handle columns if they exist
      %w[slug permalink handle].each do |col|
        next unless Product.column_names.include?(col)
        begin
          found = Product.find_by(col => key)
          return found if found
        rescue StandardError
        end
      end

      # 3) FriendlyId
      if Product.respond_to?(:friendly)
        begin
          found = Product.friendly.find(key) rescue nil
          return found if found
        rescue StandardError
        end
      end

      # 4) By name
      if Product.column_names.include?('name')
        param_name = key.tr('-', ' ')
        found = Product.where('lower(name) = ?', param_name.downcase).first
        return found if found
      end

      # 5) Slug-like again with parameterized name
      %w[slug permalink handle].each do |col|
        next unless Product.column_names.include?(col)
        param_candidate = params[:id].to_s.parameterize
        found = Product.where("#{col} = ?", param_candidate).first
        return found if found
      end

      # If nothing found, cache nil (to avoid repeated DB hits on bad ids)
      nil
    end
  end
end