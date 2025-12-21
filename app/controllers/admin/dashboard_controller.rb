module Admin
  class DashboardController < AdminController
    def index
      @total_products = Product.count
      @total_orders = Order.count
      @total_users = User.count
      @pending_orders = Order.where(status: 0).count
      @recent_orders = Order.order(created_at: :desc).limit(10)
      @low_stock_products = Product.where('stock_quantity < ?', 10).where(status: 1).limit(10)
    end
  end
end
