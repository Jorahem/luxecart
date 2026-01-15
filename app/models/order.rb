class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy

  enum payment_status: { pending: 0, paid: 1, failed: 2 }, _prefix: true

  validates :full_name, :email, :shipping_street, :shipping_city, :shipping_postal_code, presence: true
end