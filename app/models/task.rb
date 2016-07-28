class Task < ActiveRecord::Base
  # Associations
  belongs_to :user

  # Validators
  validates :name, presence: true
  validates :user_id, presence: true

  # States
  state_machine :state, :initial => :new do
    after_transition :new => :started, do: :on_start

    event :start do
      transition :new => :started
    end

    state :new do
      def initial?
        true
      end
    end
  end

  private
    def on_start
      update_attribute :started_at, DateTime.now
    end
end
