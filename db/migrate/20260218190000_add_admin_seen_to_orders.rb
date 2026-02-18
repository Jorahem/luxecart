class AddAdminSeenToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :admin_seen, :boolean, default: false, null: false
  end
end