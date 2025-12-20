class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Enums
  enum role: { customer: 0, admin: 1, super_admin: 2 }

  # Associations
  has_one :cart, dependent: :destroy
  has_one :wishlist, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :addresses, dependent: :destroy

  # Scopes
  scope :customer, -> { where(role: :customer) }
  scope :admins, -> { where(role: [:admin, :super_admin]) }

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
    role == 'admin' || role == 'super_admin'
  end

  def super_admin?
    role == 'super_admin'
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
