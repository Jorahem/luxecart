class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :order_number, null: false
      t.references :user, null: false, foreign_key: true
      t.decimal :subtotal, precision: 10, scale: 2
      t.decimal :tax_amount, precision: 10, scale: 2
      t.decimal :shipping_cost, precision: 10, scale: 2
      t.decimal :discount_amount, precision: 10, scale: 2
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.integer :status, default: 0
      t.integer :payment_status, default: 0
      t.string :payment_method
      t.string :stripe_payment_intent_id
      t.string :tracking_number
      t.text :notes
      t.datetime :cancelled_at
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.string :coupon_code
      t.timestamps
    end
    add_index :orders, :order_number, unique: true
    add_index :orders, :status
    add_index :orders, :payment_status
  end
end