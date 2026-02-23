class User < ApplicationRecord
  # Add :trackable so Devise updates sign_in_count, current_sign_in_at, etc.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_one_attached :profile_image

  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :addresses, dependent: :destroy

  has_one :cart, dependent: :destroy
  has_one :wishlist, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }

  before_save :normalize_email

  scope :admins, -> { where(admin: true) }
  scope :customers, -> { where(admin: false) }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def admin?
    !!admin
  end

  def block!
    update(blocked: true)
  end

  def unblock!
    update(blocked: false)
  end

  def blocked?
    !!blocked
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end