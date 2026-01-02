class ProductsController < ApplicationController
  def index
    @products = Product. active
      .includes(:category, :brand)
      .page(params[:page])
      .per(12)
    
    # Apply filters
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
    @products = @products.where(brand_id: params[:brand_id]) if params[:brand_id].present?
  end
  
  def show
    @product = Product.friendly. find(params[:id])
    @reviews = @product.reviews. includes(:user).order(created_at: :desc).page(params[:page]).per(10)
    @related_products = @product.category&.products&.active&.where. not(id: @product.id)&.limit(4) || []
  end
end