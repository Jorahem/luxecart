class Brand < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  # Associations
  has_many :products, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  # Fixed column name from website_url to website to match schema
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(['http', 'https']), message: 'must be a valid URL' }, allow_blank: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :featured, -> { where(featured: true) }
  scope :ordered_by_name, -> { order(:name) }

  def products_count
    products.count
  end

  def active_products_count
    products.active.count
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end