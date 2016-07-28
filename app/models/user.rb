class User < ActiveRecord::Base

  attr_accessor :password, :password_confirmation
  ROLES = %w(ADMIN USER)

  # Associations
  has_many :tasks, dependent: :destroy

  # Validators
  validates :email, uniqueness: true
  validates :email, presence: true
  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}

  validates :encrypted_password, presence: true

  validates :password, confirmation: true

  validates :role, inclusion: {in: ROLES}


  # Callbacks
  before_create :encrypt_password

  def encrypt_password
    self.encrypted_password = BCrypt::Password.create(@password).to_s if @password.present? && @password == @password_confirmation
  end
end
