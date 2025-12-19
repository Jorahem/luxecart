class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :compare_price, precision: 10, scale: 2
      t.decimal :cost_price, precision: 10, scale: 2
      t.string :sku, null: false
      t.string :barcode
      t.integer :stock_quantity, default: 0
      t.boolean :track_inventory, default: true
      t.string :slug, null: false
      t.integer :status, default: 0
      t.boolean :featured, default: false
      t.decimal :weight
      t.string :weight_unit
      t.string :meta_title
      t.text :meta_description
      t.string :tags, array: true, default: []
      t.integer :views_count, default: 0
      t.integer :sales_count, default: 0
      t.references :category, foreign_key: true
      t.references :brand, foreign_key: true
      t.timestamps
    end
    add_index :products, :slug, unique: true
    add_index :products, :sku, unique: true
    add_index :products, :status
    add_index :products, :featured
  end
end