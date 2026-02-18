class AddNotifiedToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :notified, :boolean, default: false
  end
end