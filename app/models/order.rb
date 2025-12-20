class Order < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :order_items, dependent: :destroy

  # Validations
  validates :order_number, presence: true, uniqueness: true
  validates :total_price, presence: true, numericality: { greater_than: 0 }

  # Callbacks
  before_validation :generate_order_number, on: :create
  before_save :calculate_totals

  # Enums
  enum status: { pending: 0, processing: 1, shipped: 2, delivered: 3, cancelled: 4, refunded: 5 }
  enum payment_status: { unpaid: 0, paid: 1, failed: 2, refunded: 3 }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :paid, -> { where(payment_status: :paid) }

  # Instance methods
  def total_items
    order_items.sum(:quantity)
  end

  private

  def generate_order_number
    self.order_number = "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end

  def calculate_totals
    self.subtotal = order_items.sum { |item| item.quantity * item.unit_price }
    self.tax_amount = (subtotal || 0) * 0.10
    self.shipping_cost ||= 9.99
    self.discount_amount ||= 0
    self.total_price = (subtotal || 0) + (tax_amount || 0) + (shipping_cost || 0) - (discount_amount || 0)
  end
end
