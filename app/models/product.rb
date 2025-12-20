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

  def average_rating
    reviews.average(:rating).to_f.round(1)
  end

  def current_price
    compare_price.present? && compare_price > 0 ? compare_price : price
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
