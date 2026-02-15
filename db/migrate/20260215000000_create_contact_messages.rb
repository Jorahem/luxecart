class CreateContactMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_messages do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :subject
      t.text :message, null: false

      t.boolean :read, null: false, default: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :contact_messages, :email
    add_index :contact_messages, :read
    add_index :contact_messages, :created_at
  end
end