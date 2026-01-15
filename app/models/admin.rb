class Admin < ApplicationRecord
  has_secure_password # requires bcrypt gem

  ROLES = %w[super_admin admin manager].freeze

  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: ROLES }

  # Example helper methods for role checks
  def super_admin?
    role == "super_admin"
  end

  def admin?
    role == "admin" || super_admin?
  end

  def manager?
    role == "manager"
  end

  # Remember me token
  def set_remember_token!(expires_in: 30.days)
    token = SecureRandom.urlsafe_base64(32)
    update!(remember_token: token, remember_token_expires_at: Time.current + expires_in)
    token
  end

  def clear_remember_token!
    update!(remember_token: nil, remember_token_expires_at: nil)
  end
end