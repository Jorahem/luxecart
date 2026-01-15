class CreateOrdersAndOrderItems < ActiveRecord::Migration[6.0]
  def change
    # Orders table: create if missing, otherwise add missing columns
    if table_exists?(:orders)
      add_column :orders, :shipping_full_name, :string unless column_exists?(:orders, :shipping_full_name)
      add_column :orders, :shipping_phone, :string unless column_exists?(:orders, :shipping_phone)
      add_column :orders, :shipping_street, :string unless column_exists?(:orders, :shipping_street)
      add_column :orders, :shipping_city, :string unless column_exists?(:orders, :shipping_city)
      add_column :orders, :shipping_state, :string unless column_exists?(:orders, :shipping_state)
      add_column :orders, :shipping_postal_code, :string unless column_exists?(:orders, :shipping_postal_code)

      add_column :orders, :subtotal, :decimal, precision: 12, scale: 2, default: 0.0, null: false unless column_exists?(:orders, :subtotal)
      add_column :orders, :shipping_cost, :decimal, precision: 12, scale: 2, default: 0.0, null: false unless column_exists?(:orders, :shipping_cost)
      add_column :orders, :tax, :decimal, precision: 12, scale: 2, default: 0.0, null: false unless column_exists?(:orders, :tax)
      add_column :orders, :total_price, :decimal, precision: 12, scale: 2, default: 0.0, null: false unless column_exists?(:orders, :total_price)

      add_column :orders, :stripe_payment_intent_id, :string unless column_exists?(:orders, :stripe_payment_intent_id)
      add_column :orders, :status, :string, default: "pending", null: false unless column_exists?(:orders, :status)
      add_column :orders, :payment_status, :string, default: "pending", null: false unless column_exists?(:orders, :payment_status)
    else
      create_table :orders do |t|
        t.references :user, index: true, foreign_key: true, null: true

        t.string :status, default: "pending", null: false
        t.string :payment_status, default: "pending", null: false

        t.string :shipping_full_name
        t.string :shipping_phone
        t.string :shipping_street
        t.string :shipping_city
        t.string :shipping_state
        t.string :shipping_postal_code

        t.decimal :subtotal, precision: 12, scale: 2, default: 0.0, null: false
        t.decimal :shipping_cost, precision: 12, scale: 2, default: 0.0, null: false
        t.decimal :tax, precision: 12, scale: 2, default: 0.0, null: false
        t.decimal :total_price, precision: 12, scale: 2, default: 0.0, null: false

        t.string :stripe_payment_intent_id
        t.timestamps
      end
    end

    # OrderItems table: create if missing, otherwise add missing columns
    if table_exists?(:order_items)
      add_column :order_items, :unit_price, :decimal, precision: 12, scale: 2, default: 0.0, null: false unless column_exists?(:order_items, :unit_price)
      add_column :order_items, :subtotal, :decimal, precision: 12, scale: 2, default: 0.0, null: false unless column_exists?(:order_items, :subtotal)

      # Best-effort: ensure FK to orders and products exists (won't raise if not supported)
      if respond_to?(:foreign_keys)
        fk_order = foreign_keys(:order_items).any? { |fk| fk.to_table.to_s == 'orders' } rescue false
        add_foreign_key :order_items, :orders unless fk_order
        fk_prod = foreign_keys(:order_items).any? { |fk| fk.to_table.to_s == 'products' } rescue false
        add_foreign_key :order_items, :products unless fk_prod
      end
    else
      create_table :order_items do |t|
        t.references :order, null: false, foreign_key: true
        t.references :product, null: false, foreign_key: true
        t.integer :quantity, null: false, default: 1
        t.decimal :unit_price, precision: 12, scale: 2, null: false, default: 0.0
        t.decimal :subtotal, precision: 12, scale: 2, null: false, default: 0.0
        t.timestamps
      end
    end
  end
end
