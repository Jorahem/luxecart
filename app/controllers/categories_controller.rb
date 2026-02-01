class CategoriesController < ApplicationController
  SPECIAL_CATEGORY_SLUGS = %w[
    shoes men women children decor furniture lighting tables new-arrivals new_arrivals newarrivals
    sale textiles
  ].freeze

  def index
    @categories = Category.active.root.order(:name)
  end

  def show
    @category = Category.friendly.find(params[:id])

    # Make /categories/:id match /products?category=...
    # by reusing the same param value ProductsController expects.
    params_category = @category.name.to_s.parameterize

    products = Product.all
    products = products.includes(:categories) if Product.reflect_on_association(:categories)

    # same "NORMAL CATEGORY FILTER" as ProductsController#index
    selected_category = nil
    if params_category.match?(/\A\d+\z/)
      selected_category = Category.find_by(id: params_category.to_i)
    else
      if Category.column_names.include?('slug')
        selected_category = Category.find_by(slug: params_category) rescue nil
      end
      if selected_category.nil? && Category.column_names.include?('name')
        selected_category ||= Category.where('lower(name) = ?', params_category.downcase).first
      end
    end
    selected_category ||= @category

    if selected_category
      if Product.reflect_on_association(:categories)
        products = products.joins(:categories).where(categories: { id: selected_category.id }).distinct
      else
        products = products.where(category_id: selected_category.id) if Product.column_names.include?('category_id')
      end
    else
      products = products.none
    end

    # same default sort as ProductsController#index
    if Product.column_names.include?('featured')
      products = products.order(featured: :desc, created_at: :desc)
    else
      products = products.order(created_at: :desc)
    end

    # pagination
    if defined?(Kaminari)
      @products = products.page(params[:page]).per(12)
    else
      @products = products.limit(100)
    end

    @subcategories = @category.subcategories.active rescue []

    # If you want /categories/accessories to be the SAME as products filter page,
    # do NOT render category_shop here.
    # (So we remove that special render behavior.)
  end
end