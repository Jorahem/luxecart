class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy

  enum payment_status: { pending: 0, paid: 1, failed: 2 }, _prefix: true


    enum status: { pending: 0, paid: 1, shipped: 2, delivered: 3 }

  # The DB stores the customer's name as `shipping_full_name` (snapshot fields).
  # Validate the shipping snapshot fields which are present in the schema.
  validates :shipping_full_name, :shipping_street, :shipping_city, :shipping_postal_code, presence: true

  # Ensure we have an order_number for DB NOT NULL constraint.
  before_create :generate_order_number

  # Provide a convenience `full_name` accessor used in views/calls that expect it.
  # Prefer the snapshot shipping_full_name, otherwise fall back to the user's full_name if available.
  def full_name
    shipping_full_name.presence || user&.full_name
  end

  private

  # Generates a reasonably human-friendly and unique order number.
  # Format example: ORD20260117-4f3c9a8b
  def generate_order_number
    return if order_number.present?

    # Try until unique (should succeed quickly)
    loop do
      candidate = "ORD#{Time.now.strftime('%Y%m%d')}-#{SecureRandom.hex(4)}"
      unless self.class.exists?(order_number: candidate)
        self.order_number = candidate
        break
      end
    end
  end
end