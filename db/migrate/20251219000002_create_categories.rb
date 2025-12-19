class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :parent_id
      t.integer :position, default: 0
      t.boolean :active, default: true
      t.string :meta_title
      t.text :meta_description

      t.timestamps
    end

    add_index :categories, :slug, unique: true
    add_index :categories, :parent_id
    add_index :categories, :active
  end
end