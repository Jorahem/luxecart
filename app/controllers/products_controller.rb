class ProductsController < ApplicationController
  def index
    # Use integer page and per_page variables
    page     = (params[:page] || 1).to_i
    per_page = 12

    # Ensure you call Product.active (no stray space)
    products_relation = Product.active.includes(:category, :brand).order(:name)

    if products_relation.respond_to?(:page)
      # Kaminari (or a compatible gem) is present
      @products = products_relation.page(page).per(per_page)
    else
      # Fallback: simple limit/offset pagination
      offset = (page - 1) * per_page
      @products = products_relation.limit(per_page).offset(offset)
    end

    # Apply other filters here (keep them after pagination selection if they modify the relation)
  end

  def show
    @product = Product.find(params[:id])
  end
end