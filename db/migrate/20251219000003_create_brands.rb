class CreateBrands < ActiveRecord::Migration[7.1]
  def change
    create_table :brands do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :website
      t.boolean :active, default: true
      t.timestamps
    end
    add_index :brands, :slug, unique: true
    add_index :brands, :active
  end
end