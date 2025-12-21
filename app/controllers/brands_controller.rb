class BrandsController < ApplicationController
  def index
    @brands = Brand.where(active: true).order(:name)
  end

  def show
    @brand = Brand.find(params[:id])
    @products = Product.where(status: 1, brand_id: @brand.id).limit(12)
  end
end