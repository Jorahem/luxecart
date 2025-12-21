class User < ApplicationRecord
  # Secure password
  has_secure_password

  # Role constants
  ROLE_CUSTOMER = 0
  ROLE_ADMIN = 1

  # Associations
  has_one :cart, dependent: :destroy
  has_one :wishlist, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :addresses, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }

  # Callbacks
  before_save :normalize_email

  # Instance methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def admin?
    role.to_i == ROLE_ADMIN
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
