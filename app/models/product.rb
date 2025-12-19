class Product < ApplicationRecord
  extend FriendlyId
  include PgSearch::Model

  # FriendlyId configuration
  friendly_id :name, use: [:slugged, :finders]

  # PgSearch configuration
  pg_search_scope :search_by_full_text,
                  against: [:name, :description],
                  associated_against: {
                    category: :name,
                    brand: :name
                  },
                  using: {
                    tsearch: { prefix: true, any_word: true }
                  }

  # Associations
  belongs_to :category
  belongs_to :brand
  has_many :product_images, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :product_variants, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, presence: true, uniqueness: true
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where('stock_quantity > ?', 0) }
  scope :featured, -> { where(featured: true) }
  scope :on_sale, -> { where('sale_price IS NOT NULL AND sale_price < price') }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_brand, ->(brand_id) { where(brand_id: brand_id) }
  scope :price_range, ->(min, max) { where(price: min..max) }

  # Instance methods
  def current_price
    sale_price.present? && sale_price < price ? sale_price : price
  end

  def on_sale?
    sale_price.present? && sale_price < price
  end

  def in_stock?
    stock_quantity > 0
  end

  def discount_percentage
    return 0 unless on_sale?
    ((price - sale_price) / price * 100).round(2)
  end

  def average_rating
    reviews.average(:rating).to_f.round(1)
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
