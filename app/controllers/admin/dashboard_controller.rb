module Admin
  class DashboardController < AdminController
    def index
      @total_revenue = Order.paid.sum(:total_price)
      @total_orders = Order.count
      @total_customers = User.customer.count
      @total_products = Product.count
      @recent_orders = Order.includes(:user).recent.limit(10)
      @low_stock_products = Product.active.where('stock_quantity < ?', 10).limit(10)
      @pending_reviews = Review.pending.limit(10)
    end
  end
end
