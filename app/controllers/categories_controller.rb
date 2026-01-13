class CategoriesController < ApplicationController
  def index
    @categories = Category.active.root.order(:name)
  end

  def show
    @category = Category.friendly.find(params[:id])

    products_relation = @category.products.active.includes(:product_images, :brand).order(:name)

    # pagination fallback: if a pagination gem (kaminari) is present use it, otherwise simple limit/offset
    page = (params[:page] || 1).to_i
    per_page = 12
    if products_relation.respond_to?(:page)
      @products = products_relation.page(page).per(per_page)
    else
      offset = (page - 1) * per_page
      @products = products_relation.limit(per_page).offset(offset)
    end

    @subcategories = @category.subcategories.active
  end
end