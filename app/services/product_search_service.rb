class ProductSearchService
  def initialize(params = {})
    @params = params
    @query = params[:query]
    @category_id = params[:category_id]
    @brand_id = params[:brand_id]
    @min_price = params[:min_price]
    @max_price = params[:max_price]
    @sort_by = params[:sort] || 'created_at_desc'
    @in_stock_only = params[:in_stock_only] == 'true'
    @on_sale_only = params[:on_sale_only] == 'true'
    @featured_only = params[:featured_only] == 'true'
  end

  def search
    products = Product.active.includes(:category, :brand)
    
    # Text search
    products = products.search_by_full_text(@query) if @query.present?
    
    # Category filter
    products = products.where(category_id: @category_id) if @category_id.present?
    
    # Brand filter
    products = products.where(brand_id: @brand_id) if @brand_id.present?
    
    # Price range filter
    if @min_price.present? || @max_price.present?
      min = @min_price.to_f || 0
      max = @max_price.to_f || Float::INFINITY
      products = products.where(price: min..max)
    end
    
    # Stock availability filter
    products = products.where('stock_quantity > 0') if @in_stock_only
    
    # Sale items filter
    products = products.where('compare_price IS NOT NULL AND compare_price > price') if @on_sale_only
    
    # Featured filter
    products = products.where(featured: true) if @featured_only
    
    # Apply sorting
    products = apply_sorting(products)
    
    products
  end

  private

  def apply_sorting(products)
    case @sort_by
    when 'price_asc'
      products.order(price: :asc)
    when 'price_desc'
      products.order(price: :desc)
    when 'name_asc'
      products.order(name: :asc)
    when 'name_desc'
      products.order(name: :desc)
    when 'newest'
      products.order(created_at: :desc)
    when 'oldest'
      products.order(created_at: :asc)
    when 'popular'
      products.order(sales_count: :desc, views_count: :desc)
    when 'rating'
      products.left_joins(:reviews)
              .group('products.id')
              .order('AVG(reviews.rating) DESC NULLS LAST')
    else
      products.order(created_at: :desc)
    end
  end
end
