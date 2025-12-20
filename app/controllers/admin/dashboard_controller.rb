module Admin
  class DashboardController < Admin::AdminController
    def index
      @total_orders = Order.count
      @total_users = User.count
      @total_products = Product.count
      @total_revenue = Order.where(payment_status: :paid).sum(:total_price)
      @recent_orders = Order.includes(:user).order(created_at: :desc).limit(10)
      @low_stock_products = Product.where('stock_quantity < ?', 10).limit(10)
      @pending_reviews = Review.where(status: :pending).count
    rescue => e
      Rails.logger.error "Dashboard Error: #{e.message}"
      @total_orders = 0
      @total_users = 0
      @total_products = 0
      @total_revenue = 0
      @recent_orders = []
      @low_stock_products = []
      @pending_reviews = 0
    end
  end
end
