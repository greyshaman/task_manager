class Task < ActiveRecord::Base
  # Associations
  belongs_to :user

  # Validators
  validates :name, presence: true
end
