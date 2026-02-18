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
  def show
  @new_order_count = Order.where(notified: false).count
  @new_orders = Order.where(notified: false).order(created_at: :desc).limit(5)
  # ...
end

def mark_notifications_as_seen
  Order.where(notified: false).update_all(notified: true)
  head :ok
end
end