class HomeController < ApplicationController
  def index
    @featured_products = Product.where(status: 1, featured: true).limit(8)
    @categories = Category.where(active: true, parent_id: nil).limit(6)
    @new_arrivals = Product.where(status: 1).order(created_at: :desc).limit(8)
  end
end