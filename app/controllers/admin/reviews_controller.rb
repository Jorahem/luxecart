module Admin
  class ReviewsController < AdminController
    before_action :set_review, only: [:show, :approve, :reject, :destroy]

    def index
      @reviews = Review.includes(:user, :product)
      @reviews = @reviews.where(status: params[:status]) if params[:status].present?
      @reviews = @reviews.order(created_at: :desc).page(params[:page]).per(20)
    end

    def show
    end

    def approve
      if @review.update(status: :approved)
        redirect_to admin_reviews_path, notice: 'Review was approved.'
      else
        redirect_to admin_reviews_path, alert: 'Failed to approve review.'
      end
    end

    def reject
      if @review.update(status: :rejected)
        redirect_to admin_reviews_path, notice: 'Review was rejected.'
      else
        redirect_to admin_reviews_path, alert: 'Failed to reject review.'
      end
    end

    def destroy
      @review.destroy
      redirect_to admin_reviews_url, notice: 'Review was successfully deleted.'
    end

    private

    def set_review
      @review = Review.find(params[:id])
    end
  end
end
