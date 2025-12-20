class CreateProductVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :sku, null: false
      t.string :name
      t.decimal :price, precision: 10, scale: 2
      t.decimal :compare_price, precision: 10, scale: 2
      t.integer :stock_quantity, default: 0
      t.string :option1_name
      t.string :option1_value
      t.string :option2_name
      t.string :option2_value
      t.string :option3_name
      t.string :option3_value
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :product_variants, :sku, unique: true
    add_index :product_variants, :active
  end
end
