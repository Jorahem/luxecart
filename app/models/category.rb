class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  # Associations
  has_many :products, dependent: :restrict_with_error
  belongs_to :parent_category, class_name: 'Category', foreign_key: 'parent_id', optional: true
  has_many :subcategories, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: { scope: :parent_id }, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validate :prevent_circular_reference

  # Scopes
  scope :active, -> { where(active: true) }
  scope :root, -> { where(parent_id: nil) }
  scope :ordered_by_name, -> { order(:name) }

  # Instance methods
  def root?
    parent_id.nil?
  end

  def has_subcategories?
    subcategories.any?
  end

  def products_count
    products.count
  end

  def all_products
    if has_subcategories?
      Product.where(category_id: [id] + subcategories.pluck(:id))
    else
      products
    end
  end

  def breadcrumb
    return [self] if root?
    parent_category.breadcrumb + [self]
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  private

  def prevent_circular_reference
    return unless parent_id

    category = Category.find_by(id: parent_id)
    while category.present?
      if category.id == id
        errors.add(:parent_id, 'cannot create circular reference')
        break
      end
      category = category.parent_category
    end
  end
end