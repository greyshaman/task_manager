class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.text :description
      t.integer :user_id, null: false
      t.string :state, null: false, default: "new"

      t.timestamps null: false
    end
  end
end
