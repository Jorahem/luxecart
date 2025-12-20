class WishlistItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wishlist

  def create
    product = Product.find(params[:product_id])
    
    unless @wishlist.products.include?(product)
      @wishlist.wishlist_items.create(product: product)
      redirect_to wishlist_path, notice: 'Product added to wishlist successfully.'
    else
      redirect_to product_path(product), alert: 'Product is already in your wishlist.'
    end
  end

  def destroy
    item = @wishlist.wishlist_items.find(params[:id])
    item.destroy
    redirect_to wishlist_path, notice: 'Product removed from wishlist.'
  end

  private

  def set_wishlist
    @wishlist = current_user.wishlist || current_user.create_wishlist
  end
end
