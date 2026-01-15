class CreateAdmins < ActiveRecord::Migration[7.0]
  def change
    create_table :admins do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :role, null: false, default: "admin" # values: super_admin, admin, manager
      t.string :remember_token
      t.datetime :remember_token_expires_at
      t.integer :failed_attempts, null: false, default: 0
      t.boolean :locked, null: false, default: false
      t.timestamps
    end
  end
end