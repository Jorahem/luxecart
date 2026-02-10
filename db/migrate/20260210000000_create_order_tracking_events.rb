class CreateOrderTrackingEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :order_tracking_events do |t|
      t.references :order, null: false, foreign_key: true
      t.string :status, null: false
      t.string :location
      t.text :message
      t.datetime :happened_at, null: false

      t.timestamps
    end

    add_index :order_tracking_events, [:order_id, :happened_at]
  end
end