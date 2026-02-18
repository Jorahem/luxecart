module AdminPanel
  class DashboardController < AdminPanel::BaseController
    layout "admin"

    def index
      @total_orders     = Order.count
      @total_revenue    = Order.sum(:total_price)
      @orders_today     = Order.where(created_at: Time.zone.today.all_day).count
      @total_users      = User.count
      @total_products   = Product.count

      @low_stock_products =
        if Product.column_names.include?("stock_quantity")
          Product.where("stock_quantity <= ?", 5).order(stock_quantity: :asc).limit(8)
        else
          []
        end

      @recent_orders = Order.order(created_at: :desc).limit(8)

      # --- New: notification logic ---
      @unseen_order_count = Order.where(admin_seen: false).count
      # When the admin visits the dashboard, mark all unseen orders as seen
      Order.where(admin_seen: false).update_all(admin_seen: true)
    end
  end
end