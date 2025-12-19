class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product

  def create
    @review = @product.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to product_path(@product), notice: 'Review submitted successfully.'
    else
      redirect_to product_path(@product), alert: 'Failed to submit review.'
    end
  end

  def destroy
    @review = current_user.reviews.find(params[:id])
    @review.destroy
    redirect_to product_path(@product), notice: 'Review deleted successfully.'
  end

  private

  def set_product
    @product = Product.friendly.find(params[:product_id])
  end

  def review_params
    params.require(:review).permit(:rating, :title, :comment)
  end
end