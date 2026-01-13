class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product

  def create
    like = current_user.likes.find_or_initialize_by(product: @product)
    if like.persisted? || like.save
      respond_to do |format|
        format.html { redirect_back fallback_location: product_path(@product), notice: 'Added to favorites.' }
        format.json { render json: { liked: true, count: @product.likes.count } }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: product_path(@product), alert: 'Could not add to favorites.' }
        format.json { render json: { error: 'Could not like' }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    like = current_user.likes.find_by(product: @product)
    if like&.destroy
      respond_to do |format|
        format.html { redirect_back fallback_location: product_path(@product), notice: 'Removed from favorites.' }
        format.json { render json: { liked: false, count: @product.likes.count } }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: product_path(@product), alert: 'Could not remove favorite.' }
        format.json { render json: { error: 'Could not unlike' }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_product
    @product = Product.friendly.find(params[:id] || params[:product_id])
  end
end