module Admin
  class DashboardController < BaseController
    def index
      @total_orders = Order.count
      @total_revenue = Order.sum(:total_price)
      @orders_today = Order.where(created_at: Time.zone.today.all_day).count
      @total_users = User.count
      @total_products = Product.count
      @low_stock_products = Product.where("stock_quantity <= ?", 5)
      @recent_orders = Order.order(created_at: :desc).limit(10)
    end
  end
end