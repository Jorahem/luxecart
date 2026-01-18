class CategoriesController < ApplicationController
  # Add new slugs here when you want the shared category_shop template to render
  SPECIAL_CATEGORY_SLUGS = %w[
    shoes men women children decor furniture lighting tables new-arrivals new_arrivals newarrivals
    sale textiles
  ].freeze

  def index
    @categories = Category.active.root.order(:name)
  end

  def show
    # Find category (friendly id if configured)
    @category = Category.friendly.find(params[:id])

    # Base product relation for this category
    products_relation = @category.products.active.includes(:product_images, :brand).order(:name)

    # Pagination: use Kaminari/WillPaginate if present, otherwise simple limit/offset
    page = (params[:page] || 1).to_i
    per_page = 12
    if products_relation.respond_to?(:page)
      @products = products_relation.page(page).per(per_page)
    else
      offset = (page - 1) * per_page
      @products = products_relation.limit(per_page).offset(offset)
    end

    # Subcategories (if any)
    @subcategories = @category.subcategories.active

    # If this category is in the special list, render the shared special template.
    slug = @category.name.to_s.parameterize
    if SPECIAL_CATEGORY_SLUGS.include?(slug)
      render 'category_shop' and return
    end

    # Otherwise render default show template
  end
end