class AddStatusTimingAttrsToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :started_at, :datetime
    add_column :tasks, :finished_at, :datetime
  end
end
