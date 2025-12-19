class BrandsController < ApplicationController
  def index
    @brands = Brand.active.order(:name)
  end

  def show
    @brand = Brand.friendly.find(params[:id])
    @products = @brand.products.active.page(params[:page]).per(12)
  end
end