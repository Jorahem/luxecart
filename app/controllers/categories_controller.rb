class CategoriesController < ApplicationController
  def index
    @categories = Category.where(active: true, parent_id: nil).order(:name)
  end

  def show
    @category = Category.find(params[:id])
    @products = Product.where(status: 1, category_id: @category.id).limit(12)
    @subcategories = Category.where(active: true, parent_id: @category.id)
  end
end