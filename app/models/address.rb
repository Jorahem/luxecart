class Address < ApplicationRecord
  belongs_to :user
  enum address_type: { shipping: 0, billing: 1, both: 2 }

  validates :first_name, :last_name, :street_address, :city, :state, :postal_code, :country, presence: true

  before_save :ensure_only_one_default, if: :is_default?

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def single_line
    [street_address, apartment, city, state, postal_code, country].compact.join(', ')
  end

  private

  def ensure_only_one_default
    user.addresses.where.not(id: id).update_all(is_default: false)
  end
end