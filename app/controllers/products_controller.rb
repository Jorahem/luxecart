class ProductsController < ApplicationController
  def index
    # Use integer page and per_page variables
    page     = (params[:page] || 1).to_i
    per_page = 12

    # Base relation
    products_relation = Product.active.includes(:category, :brand, :product_images).order(:name)

    # Apply basic filters (search, brand, price, sort)
    if params[:q].present?
      q = "%#{params[:q].strip.downcase}%"
      products_relation = products_relation.where("LOWER(name) LIKE ? OR LOWER(description) LIKE ? OR LOWER(sku) LIKE ?", q, q, q)
    end

    if params[:brand].present?
      brand_ids = Array(params[:brand]).map(&:to_i)
      products_relation = products_relation.where(brand_id: brand_ids)
    end

    if params[:min_price].present? || params[:max_price].present?
      min = params[:min_price].to_f if params[:min_price].present?
      max = params[:max_price].to_f if params[:max_price].present?
      if min && max
        products_relation = products_relation.where(price: min..max)
      elsif min
        products_relation = products_relation.where("price >= ?", min)
      elsif max
        products_relation = products_relation.where("price <= ?", max)
      end
    end

    case params[:sort]
    when 'price_asc'
      products_relation = products_relation.order(price: :asc)
    when 'price_desc'
      products_relation = products_relation.order(price: :desc)
    when 'newest'
      products_relation = products_relation.order(created_at: :desc)
    end

    # Pagination fallback (Kaminari if present)
    if products_relation.respond_to?(:page)
      @products = products_relation.page(page).per(per_page)
    else
      offset = (page - 1) * per_page
      @products = products_relation.limit(per_page).offset(offset)
    end
  end

  def show
    @product = Product.friendly.find(params[:id])
  end
end