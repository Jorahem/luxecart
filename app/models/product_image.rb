class ProductImage < ApplicationRecord
  belongs_to :product
  has_one_attached :image

  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :image, presence: true

  scope :ordered, -> { order(position: :asc) }
  scope :primary, -> { where(is_primary: true) }

  before_save :ensure_single_primary

  private

  def ensure_single_primary
    if is_primary? && is_primary_changed?
      ProductImage.where(product_id: product_id).where.not(id: id).update_all(is_primary: false)
    end
  end
end
