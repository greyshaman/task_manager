class ChangeAtrributesOptionsOnUsers < ActiveRecord::Migration
  def change
    change_column :users, :email, :string, null: false
    change_column :users, :encrypted_password, :string, null: false
    change_column :users, :role, :string, null: false, default: 'USER'
  end
end
