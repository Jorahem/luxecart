class ProductsController < ApplicationController
  def index
    @products = Product.where(status: 1).includes(:category, :brand)
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
    @products = @products.where(brand_id: params[:brand_id]) if params[:brand_id].present?
    @products = @products.where("name LIKE ? OR description LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%") if params[:query].present?
    
    if params[:min_price].present? || params[:max_price].present?
      min = params[:min_price].to_f || 0
      max = params[:max_price].to_f || Float::INFINITY
      @products = @products.where(price: min..max)
    end
    
    @products = case params[:sort]
                when 'price_low' then @products.order(price: :asc)
                when 'price_high' then @products.order(price: :desc)
                when 'newest' then @products.order(created_at: :desc)
                when 'popular' then @products.order(sales_count: :desc)
                else @products.order(created_at: :desc)
                end
    
    @products = @products.limit(12).offset((params[:page].to_i - 1) * 12) if params[:page].present?
    @categories = Category.where(active: true)
    @brands = Brand.where(active: true)
  end

  def show
    @product = Product.find(params[:id])
    @related_products = Product.active.where(category_id: @product.category_id).where.not(id: @product.id).limit(4)
    @reviews = @product.reviews.where(status: 1).order(created_at: :desc).limit(10)
    @product.increment!(:views_count)
  end
end