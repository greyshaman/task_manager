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

  validates :password, presence: true, if: Proc.new {|_user| _user.new_record? || _user.password_confirmation.present?}
  validates :password_confirmation, presence: true, if: Proc.new {|_user| _user.new_record? || _user.password.present?}

  validates :password, confirmation: true

  validates :role, inclusion: {in: ROLES}


  # Callbacks
  before_validation :encrypt_password, if: Proc.new {|_user| _user.password.present? || _user.password_confirmation.present?}

  def self.authenticate(email, password)
    user = User.find_by_email(email.downcase)
    if user && BCrypt::Password.new(user.encrypted_password) == password
      user
    else
      nil
    end
  end

  def user?
    role == "USER"
  end

  def admin?
    role == "ADMIN"
  end

  def encrypt_password
    self.encrypted_password = BCrypt::Password.create(@password).to_s if @password.present? && @password == @password_confirmation
  end
end
