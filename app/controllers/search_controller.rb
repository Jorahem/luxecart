class SearchController < ApplicationController
  def index
    @query = params[:q]
    @products = Product.active.includes(:category, :brand)
    
    if @query.present?
      @products = @products.search_by_full_text(@query)
    end
    
    # Apply filters
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
    @products = @products.where(brand_id: params[:brand_id]) if params[:brand_id].present?
    
    # Price range
    if params[:min_price].present? || params[:max_price].present?
      min = params[:min_price].to_f || 0
      max = params[:max_price].to_f || Float::INFINITY
      @products = @products.where(price: min..max)
    end
    
    # Sorting
    @products = case params[:sort]
                when 'price_low' then @products.order(price: :asc)
                when 'price_high' then @products.order(price: :desc)
                when 'newest' then @products.order(created_at: :desc)
                when 'popular' then @products.order(sales_count: :desc)
                else @products.order(created_at: :desc)
                end
    
    @products = @products.page(params[:page]).per(12)
    @categories = Category.active
    @brands = Brand.active
  end
end
