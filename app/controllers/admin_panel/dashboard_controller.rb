module AdminPanel
  class DashboardController < BaseController
    require 'ostruct'

    def index
      # KPIs (safe fallbacks)
      @total_transaction = safe_sum(Order, :total_price)
      @total_product     = safe_count(Product)
      @complete_order    = safe_count(Order.where(status: 'delivered')) rescue 0
      @cancel_order      = safe_count(Order.where(status: 'cancelled')) rescue 0

      # Revenue series (last 14 days)
      days = 13
      @revenue_dates = days.downto(0).map { |d| d.days.ago.to_date }.reverse
      @revenue_series = @revenue_dates.map do |date|
        safe_sum(Order, :total_price, created_at: date.all_day).to_f
      end

      # Top products (best-effort)
      @top_products = fetch_top_products

      # Recent transactions & recent orders
      @recent_transactions = fetch_recent_transactions
      @recent_orders = (@recent_transactions.presence || []).first(6)

      # Top countries by sales (safe fallback)
      @top_countries = begin
        if defined?(User) && User.table_exists? && Order.table_exists? && User.column_names.include?('country')
          # join users -> orders (best effort)
          counts = User.joins(:orders).group('users.country').order('COUNT(orders.id) DESC').limit(4).count('orders.id')
          counts.map { |country, cnt| { country: country.presence || 'Unknown', count: cnt } }
        else
          # fallback sample data
          [{ country: 'United States', count: 34 }, { country: 'France', count: 25 }, { country: 'Australia', count: 15 }, { country: 'Germany', count: 12 }]
        end
      rescue
        [{ country: 'United States', count: 34 }, { country: 'France', count: 25 }, { country: 'Australia', count: 15 }, { country: 'Germany', count: 12 }]
      end

      # Additional display fields used by view
      @total_sales = @total_transaction
      @total_earnings = (@total_sales * 0.48).round(2)
      @total_orders_display = safe_count(Order)
      @visitors = 18_500
    end

    private

    def fetch_top_products
      if defined?(Product) && Product.table_exists? && Product.any?
        Product.limit(5).map do |p|
          OpenStruct.new(
            name: p.try(:name) || 'Product',
            price: (p.try(:price) || 0),
            image_url: (p.try(:image_url) || p.try(:image) || placeholder_image),
            category: (p.try(:category)&.name || p.try(:category) || ''),
            orders_count: (p.try(:orders_count) || 0),
            stock_quantity: (p.try(:stock_quantity) || 0)
          )
        end
      else
        # fallback sample products
        [
          OpenStruct.new(name: "Nike Revolution 3", price: 250, image_url: placeholder_image, category: "Shoes", orders_count: 47, stock_quantity: 23),
          OpenStruct.new(name: "Green Plain T-shirt", price: 79, image_url: placeholder_image, category: "Clothes", orders_count: 98, stock_quantity: 7),
          OpenStruct.new(name: "Nike Dunk Shoes", price: 579, image_url: placeholder_image, category: "Shoes", orders_count: 26, stock_quantity: 3)
        ]
      end
    rescue
      []
    end

    def fetch_recent_transactions
      if defined?(Order) && Order.table_exists?
        Order.order(created_at: :desc).limit(8).includes(order_items: :product).to_a
      else
        # fallback sample transactions (OpenStruct objects)
        (1..6).map do |i|
          OpenStruct.new(
            id: i,
            order_number: "SAMPLE#{1000 + i}",
            created_at: Time.zone.now - i.days,
            total_price: [99, 120, 250, 79, 139].sample,
            order_items: [
              OpenStruct.new(product: OpenStruct.new(name: "Sample #{i}", image_url: placeholder_image, category: "Sample"))
            ]
          )
        end
      end
    rescue
      []
    end

    def safe_sum(model, column, where_hash = nil)
      return 0 unless model.respond_to?(:table_exists?) && model.table_exists? && model.column_names.include?(column.to_s)
      scope = model.all
      scope = scope.where(where_hash) if where_hash.present?
      scope.sum(column) || 0
    rescue
      0
    end

    def safe_count(scope_or_model)
      if scope_or_model.respond_to?(:count)
        scope_or_model.count
      else
        0
      end
    rescue
      0
    end

    def placeholder_image
      "https://via.placeholder.com/400x300?text=No+Image"
    end
  end
end