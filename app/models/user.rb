class User < ActiveRecord::Base

  # Validators
  validates :email, uniqueness: true
  validates :email, presence: true
  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}

  validates :encrypted_password, presence: true

  attr_writer :password

  # Callbacks
  before_create :encrypt_password

  def encrypt_password
    self.encrypted_password = BCrypt::Password.create(@password).to_s
  end
end
