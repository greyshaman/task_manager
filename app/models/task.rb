class Task < ActiveRecord::Base
  # Associations
  belongs_to :user

  # Validators
  validates :name, presence: true
  validates :user_id, presence: true

  # States
  state_machine :state, initial: :new do
    before_transition any => :started do |task, transition|
      task.started_at = DateTime.now
    end
    before_transition started: :finished do |task, transition|
      task.finished_at = DateTime.now
    end

    event :start do
      transition :new => :started
    end

    event :finish do
      transition started: :finished
    end

    event :reactivate do
      transition finished: :started
    end
  end

  # Scopes
  scope :initiated, ->{where(state: 'new')}
  scope :started, ->{where(state: 'started')}
  scope :finished, ->{where(state: 'finished')}

  # Attachments
  mount_uploader :attachment, AttachmentUploader
end
