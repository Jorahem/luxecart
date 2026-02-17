class AddReplyToContactMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :contact_messages, :reply, :text
    add_column :contact_messages, :reply_at, :datetime
  end
end
