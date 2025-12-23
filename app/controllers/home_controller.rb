class HomeController < ApplicationController
  def index
    @featured_products = Product.active.featured.includes(:brand, :category).limit(8)
    @categories = Category.active.root.limit(6)
    @new_arrivals = Product.active.includes(:brand, :category).order(created_at: :desc).limit(8)
  end
end