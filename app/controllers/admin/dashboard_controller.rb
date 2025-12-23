module Admin
  class DashboardController < AdminController
    def index
      @total_orders = Order.count
      @total_users = User.count
      @total_products = Product.count
      @total_revenue = Order.paid.sum(:total_price)
      @recent_orders = Order.includes(:user, :order_items).order(created_at: :desc).limit(10)
      @low_stock_products = Product.where('stock_quantity < ?', 10).includes(:category, :brand).limit(10)
    end
  end
end
