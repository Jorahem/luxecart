module Admin
  class ReviewsController < AdminController
    before_action :set_review, only: [:show, :approve, :reject]

    def index
      @reviews = Review.includes(:user, :product).order(created_at: :desc).page(params[:page]).per(20)
      @reviews = @reviews.where(status: params[:status]) if params[:status].present?
    end

    def show
    end

    def approve
      if @review.update(status: :approved)
        redirect_to admin_reviews_path, notice: 'Review was successfully approved.'
      else
        redirect_to admin_reviews_path, alert: 'Failed to approve review.'
      end
    end

    def reject
      if @review.update(status: :rejected)
        redirect_to admin_reviews_path, notice: 'Review was successfully rejected.'
      else
        redirect_to admin_reviews_path, alert: 'Failed to reject review.'
      end
    end

    private

    def set_review
      @review = Review.find(params[:id])
    end
  end
end
