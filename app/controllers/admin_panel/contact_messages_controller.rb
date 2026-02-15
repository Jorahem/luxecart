module AdminPanel
  class ContactMessagesController < BaseController
    def index
      @contact_messages = ContactMessage.recent
    end

    def show
      @contact_message = ContactMessage.find(params[:id])
    end

    def mark_read
      @contact_message = ContactMessage.find(params[:id])
      @contact_message.update!(read: true, read_at: Time.zone.now)
      redirect_to admin_contact_messages_path, notice: "Marked as read."
    end
  end
end