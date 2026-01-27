module Admin
  class ReportsController < BaseController
    def index
      # Revenue by day/month, top products, category-wise, average order value
      @revenue_by_day = Order.group_by_day(:created_at).sum(:total_price)
      @revenue_by_month = Order.group_by_month(:created_at).sum(:total_price)
      @top_products = Product.joins(:order_items).group("products.id").order("SUM(order_items.quantity) DESC").limit(10).sum("order_items.quantity")
      @category_sales = Category.joins(products: :order_items).group("categories.id").sum("order_items.total_price")
      @average_order_value = Order.average(:total_price)
    end
  end
end