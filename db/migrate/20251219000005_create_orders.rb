class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :order_number, null: false
      t.references :user, null: false, foreign_key: true

      t.decimal :subtotal, precision: 10, scale: 2, null: false, default: "0.0"
      t.decimal :tax_amount, precision: 10, scale: 2, null: false, default: "0.0"
      t.decimal :shipping_cost, precision: 10, scale: 2, null: false, default: "0.0"
      t.decimal :discount_amount, precision: 10, scale: 2, null: false, default: "0.0"
      t.decimal :total_price, precision: 10, scale: 2, null: false, default: "0.0"

      t.integer :status, null: false, default: 0
      t.integer :payment_status, null: false, default: 0

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

    # Make index creation idempotent so running migrations (or partial DB state) won't error
    add_index :orders, :order_number, unique: true unless index_exists?(:orders, :order_number)
    add_index :orders, :user_id unless index_exists?(:orders, :user_id)
    add_index :orders, :status unless index_exists?(:orders, :status)
    add_index :orders, :payment_status unless index_exists?(:orders, :payment_status)
    add_index :orders, :stripe_payment_intent_id unless index_exists?(:orders, :stripe_payment_intent_id)
  end
end