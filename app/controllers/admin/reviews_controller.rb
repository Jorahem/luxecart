module Admin
  class ReviewsController < AdminController
    before_action :set_review, only: [:approve, :reject, :destroy]

    def index
      @reviews = Review.includes(:user, :product).order(created_at: :desc).page(params[:page]).per(20)
    end

    def approve
      @review.update(status: :approved)
      redirect_to admin_reviews_path, notice: 'Review approved successfully.'
    end

    def reject
      @review.update(status: :rejected)
      redirect_to admin_reviews_path, notice: 'Review rejected successfully.'
    end

    def destroy
      @review.destroy
      redirect_to admin_reviews_path, notice: 'Review deleted successfully.'
    end

    private

    def set_review
      @review = Review.find(params[:id])
    end
  end
end
