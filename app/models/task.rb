class Task < ActiveRecord::Base
  # Associations
  belongs_to :user

  # Validators
  validates :name, presence: true
  validates :user_id, presence: true

  # States
  state_machine :state, initial: :new do
    after_transition any => :started, do: :on_start
    after_transition started: :finished, do: :on_finish

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

  private
    def on_start
      update_attribute :started_at, DateTime.now
    end

    def on_finish
      update_attribute :finished_at, DateTime.now
    end
end
