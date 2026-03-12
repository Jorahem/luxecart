class CreateAdmins < ActiveRecord::Migration[7.1]
  def change
    create_table :admins do |t|
      t.string  :email, null: false
      t.string  :password_digest, null: false
      t.string  :role, null: false, default: "admin"
      t.string  :remember_token
      t.datetime :remember_token_expires_at

      t.timestamps
    end

    add_index :admins, :email, unique: true
    add_index :admins, :remember_token
  end
end