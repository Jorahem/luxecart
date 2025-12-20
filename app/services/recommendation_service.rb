class RecommendationService
  def initialize(product = nil, user = nil)
    @product = product
    @user = user
  end

  # Products similar to the given product (based on category)
  def similar_products(limit = 4)
    return Product.none unless @product

    Product.active
           .where(category_id: @product.category_id)
           .where.not(id: @product.id)
           .order(sales_count: :desc)
           .limit(limit)
  end

  # Products frequently bought together
  def frequently_bought_together(limit = 4)
    return Product.none unless @product

    # Find products that appear in orders with this product
    Product.active
           .joins(:order_items)
           .where(order_items: {
             order_id: OrderItem.where(product_id: @product.id).select(:order_id)
           })
           .where.not(id: @product.id)
           .group('products.id')
           .select('products.*, COUNT(order_items.id) as frequency')
           .order('frequency DESC')
           .limit(limit)
  end

  # Personalized recommendations based on user's order history
  def personalized_recommendations(limit = 8)
    return Product.none unless @user

    # Get categories from user's previous orders
    user_categories = @user.orders
                           .joins(order_items: :product)
                           .pluck('products.category_id')
                           .uniq

    # Get products from those categories that user hasn't ordered
    ordered_product_ids = @user.orders
                               .joins(:order_items)
                               .pluck('order_items.product_id')

    Product.active
           .where(category_id: user_categories)
           .where.not(id: ordered_product_ids)
           .order(sales_count: :desc, views_count: :desc)
           .limit(limit)
  end

  # Trending products (most viewed/sold in last 7 days)
  def trending_products(limit = 8)
    Product.active
           .where('created_at >= ? OR updated_at >= ?', 7.days.ago, 7.days.ago)
           .order(sales_count: :desc, views_count: :desc)
           .limit(limit)
  end

  # New arrivals
  def new_arrivals(limit = 8)
    Product.active
           .order(created_at: :desc)
           .limit(limit)
  end

  # Featured products
  def featured_products(limit = 8)
    Product.active
           .where(featured: true)
           .order(sales_count: :desc)
           .limit(limit)
  end

  # Best sellers
  def best_sellers(limit = 8)
    Product.active
           .order(sales_count: :desc)
           .limit(limit)
  end

  # Products on sale
  def on_sale_products(limit = 8)
    Product.active
           .where('compare_price IS NOT NULL AND compare_price > price')
           .order('(compare_price - price) DESC')
           .limit(limit)
  end
end
