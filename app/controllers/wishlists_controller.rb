class WishlistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wishlist

  def show
    @wishlist_items = @wishlist.wishlist_items.includes(:product).page(params[:page]).per(12)
  end

  def add_item
    product = Product.find(params[:product_id])
    @wishlist.add_product(product)
    redirect_to wishlist_path, notice: 'Product added to wishlist.'
  end

  def remove_item
    product = Product.find(params[:product_id])
    @wishlist.remove_product(product)
    redirect_to wishlist_path, notice: 'Product removed from wishlist.'
  end

  private

  def set_wishlist
    @wishlist = current_user.wishlist || current_user.create_wishlist
  end
end