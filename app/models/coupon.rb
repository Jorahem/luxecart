class Coupon < ApplicationRecord
  enum discount_type: { percentage: 0, fixed_amount: 1 }

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :minimum_order_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :max_uses, numericality: { greater_than: 0, only_integer: true }, allow_nil: true
  validate :valid_date_range

  scope :active, -> { where(active: true) }
  scope :valid, -> { active.where('(valid_from IS NULL OR valid_from <= ?) AND (valid_until IS NULL OR valid_until >= ?)', Time.current, Time.current) }

  # Check if coupon is valid
  def valid_for_use?(order_total = nil)
    return false unless active?
    return false if expired?
    return false if max_uses_reached?
    return false if order_total && minimum_order_value && order_total < minimum_order_value
    true
  end

  # Check if coupon has expired
  def expired?
    return false if valid_until.nil?
    valid_until < Time.current
  end

  # Check if coupon has not started yet
  def not_started?
    return false if valid_from.nil?
    valid_from > Time.current
  end

  # Check if max uses has been reached
  def max_uses_reached?
    return false if max_uses.nil?
    current_uses >= max_uses
  end

  # Calculate discount amount
  def calculate_discount(order_total)
    return 0 unless valid_for_use?(order_total)
    
    if percentage?
      discount = (order_total * discount_value / 100).round(2)
    else
      discount = [discount_value, order_total].min
    end
    
    discount.round(2)
  end

  # Increment usage count
  def increment_usage!
    increment!(:current_uses)
  end

  # Decrement usage count (for cancelled orders)
  def decrement_usage!
    decrement!(:current_uses) if current_uses > 0
  end

  private

  def valid_date_range
    return if valid_from.blank? || valid_until.blank?
    
    if valid_from > valid_until
      errors.add(:valid_until, 'must be after valid from date')
    end
  end
end