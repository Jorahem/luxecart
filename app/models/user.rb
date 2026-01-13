class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :addresses, dependent: :destroy

  # Likes (favorites)
  has_many :likes, dependent: :destroy
  has_many :liked_products, through: :likes, source: :product

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }

  # Callbacks
  before_save :normalize_email

  # Instance methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def admin?
    role == 'admin'
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

    has_one :cart, dependent: :destroy
end