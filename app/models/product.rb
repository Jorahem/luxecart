class Product < ApplicationRecord
  extend FriendlyId
  include PgSearch::Model

  # FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  # PgSearch configuration for full-text search
  pg_search_scope :search_by_full_text,
    against: {
      name: 'A',
      description: 'B',
      sku: 'C'
    },
    using: {
      tsearch: {
        prefix: true,
        any_word: true
      }
    }

  # Associations
  belongs_to :category
  belongs_to :brand
  has_many :product_images, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :product_variants, dependent: :destroy

  # Serialize tags (SQLite-safe)
  serialize :tags, Array

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, presence: true, uniqueness: true
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # Scopes (based on REAL columns)
  scope :featured, -> { where(featured: true) }
  scope :in_stock, -> { where('stock_quantity > ?', 0) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_brand, ->(brand_id) { where(brand_id: brand_id) }
  scope :price_range, ->(min, max) { where(price: min..max) }

  # Status enum (recommended)
  enum status: { draft: 0, active: 1, archived: 2 }

  # Instance methods
  def in_stock?
    stock_quantity.positive?
  end

  def low_stock?
    stock_quantity > 0 && stock_quantity < 10
  end

  def out_of_stock?
    stock_quantity.zero?
  end

  def average_rating
    reviews.average(:rating).to_f.round(1)
  end

  def discount_percentage
    return 0 unless compare_price.present? && compare_price > price
    (((compare_price - price) / compare_price) * 100).round(0)
  end

  def on_sale?
    compare_price.present? && compare_price > price
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def decrement_stock!(quantity)
    update!(stock_quantity: stock_quantity - quantity) if stock_quantity >= quantity
  end

  def increment_stock!(quantity)
    update!(stock_quantity: stock_quantity + quantity)
  end
end
