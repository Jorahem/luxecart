class CategoriesController < ApplicationController
  def index
    @categories = Category.active.root.order(:name)
  end

  def show
    @category = Category.friendly.find(params[:id])
    @products = @category.products.active.page(params[:page]).per(12)
    @subcategories = @category.subcategories.active
  end
end