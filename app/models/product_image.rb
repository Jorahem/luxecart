class ProductImage < ApplicationRecord
  belongs_to :product
  
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  scope :ordered, -> { order(position: :asc) }
  scope :primary, -> { where(primary: true).first }
  
  before_save :ensure_only_one_primary
  
  private
  
  def ensure_only_one_primary
    if primary? && primary_changed?
      ProductImage.where(product_id: product_id, primary: true)
                  .where.not(id: id)
                  .update_all(primary: false)
    end
  end
end
