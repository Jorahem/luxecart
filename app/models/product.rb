class Product < ApplicationRecord
  extend FriendlyId

  # FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  # Associations
  belongs_to :category
  belongs_to :brand
  has_many :product_images, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :product_variants, dependent: :destroy

  # Likes association
  has_many :likes, dependent: :destroy
  has_many :likers, through: :likes, source: :user
  has_many :liked_products, through: :likes, source: :product

  # Serialize tags (SQLite-safe) - Updated for Rails 7.1+
  serialize :tags, type: Array, coder: YAML

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, presence: true, uniqueness: true
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # Scopes (based on REAL columns)
  scope :featured,    -> { where(featured: true) }
  scope :in_stock,    -> { where('stock_quantity > ?', 0) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_brand,    ->(brand_id)    { where(brand_id: brand_id) }
  scope :price_range, ->(min, max)    { where(price: min..max) }

  # Status enum (generates scopes like .active, .draft)
  enum status: { draft: 0, active: 1, archived: 2 }

  # Instance methods
  def in_stock?
    stock_quantity.positive?
  end

  def average_rating
    reviews.any? ? reviews.average(:rating).to_f.round(1) : 0.0
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  # Simple recommendation by category and popularity
  def similar_products(limit: 8)
    scope = Product.where(category_id: category_id)
                   .where.not(id: id)
                   .left_joins(:likes)
                   .group('products.id')
                   .order(Arel.sql('COUNT(likes.id) DESC'), created_at: :desc)
    scope.limit(limit)
  end

  # Full-text & fuzzy search (these assume search_vector/name indexes exist;
  # they will just act as WHERE filters; no callback needed)
  scope :full_text_search, ->(query) {
    return none if query.blank?

    sanitized = ActiveRecord::Base.sanitize_sql_array(
      ["plainto_tsquery('simple', unaccent(?))", query]
    )

    where("search_vector @@ #{sanitized}")
      .order(Arel.sql("ts_rank(search_vector, #{sanitized}) DESC"))
  }

  scope :name_fuzzy_search, ->(query, threshold: 0.3) {
    return none if query.blank?

    where("similarity(unaccent(name), unaccent(?)) >= ?", query, threshold)
      .order(Arel.sql("similarity(unaccent(name), unaccent('#{query}')) DESC"))
  }

  # Recommendation based on liked products
  def recommended_products(limit: 12)
    return Product.none if liked_products.empty?

    Product
      .joins(:likes)
      .where(
        likes: {
          user_id: User
            .joins(:likes)
            .where(likes: { product_id: liked_products.select(:id) })
            .where.not(id: id)
        }
      )
      .where.not(id: liked_products.select(:id))
      .group('products.id')
      .order(Arel.sql('COUNT(likes.id) DESC'))
      .limit(limit)
  end
end