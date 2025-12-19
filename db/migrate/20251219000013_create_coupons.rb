class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :code, null: false
      t.integer :discount_type, default: 0
      t.decimal :discount_value, precision: 10, scale: 2
      t.decimal :minimum_order_value, precision: 10, scale: 2
      t.integer :max_uses
      t.integer :current_uses, default: 0
      t.datetime :valid_from
      t.datetime :valid_until
      t.boolean :active, default: true
      t.text :description
      t.timestamps
    end
    add_index :coupons, :code, unique: true
    add_index :coupons, :active
  end
end