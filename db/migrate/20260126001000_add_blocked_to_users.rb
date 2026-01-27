# db/migrate/20260126001000_add_blocked_to_users.rb
class AddBlockedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :blocked, :boolean, default: false, null: false
  end
end