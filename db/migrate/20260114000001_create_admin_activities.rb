class CreateAdminActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :admin_activities do |t|
      t.references :admin, null: false, foreign_key: true
      t.string :action, null: false
      t.string :trackable_type
      t.bigint :trackable_id
      t.text :metadata
      t.string :ip_address
      t.timestamps
    end

    add_index :admin_activities, [:trackable_type, :trackable_id]
  end
end