module Admin
  class DashboardController < AdminController
    def index
      @total_orders = Order.count
      @total_products = Product.count
      @total_users = User.where(role: 0).count
      @total_revenue = Order.where(payment_status: :paid).sum(:total_price)
      
      # Recent orders
      @recent_orders = Order.includes(:user).order(created_at: :desc).limit(10)
      
      # Sales data for charts (last 30 days)
      @daily_sales = Order.where(payment_status: :paid)
                          .where('created_at >= ?', 30.days.ago)
                          .group("DATE(created_at)")
                          .sum(:total_price)
      
      # Top selling products
      @top_products = Product.joins(:order_items)
                             .group(:id)
                             .select('products.*, SUM(order_items.quantity) as total_sold')
                             .order('total_sold DESC')
                             .limit(10)
      
      # Low stock alerts
      @low_stock_products = Product.where('stock_quantity > 0 AND stock_quantity < 10')
                                   .order(stock_quantity: :asc)
                                   .limit(10)
    end
  end
end
