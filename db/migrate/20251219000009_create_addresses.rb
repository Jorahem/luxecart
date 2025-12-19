class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :address_type, default: 0
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :street_address, null: false
      t.string :apartment
      t.string :city, null: false
      t.string :state, null: false
      t.string :postal_code, null: false
      t.string :country, null: false, default: 'United States'
      t.string :phone
      t.boolean :is_default, default: false
      t.timestamps
    end
    add_index :addresses, :is_default
  end
end