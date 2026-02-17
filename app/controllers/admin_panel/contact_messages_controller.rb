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



    def reply
  @contact_message = ContactMessage.find(params[:id])
  if params[:contact_message] && params[:contact_message][:reply].present?
    @contact_message.update!(
      reply: params[:contact_message][:reply], 
      reply_at: Time.zone.now
    )
    redirect_to admin_contact_message_path(@contact_message), notice: "Reply sent to customer."
  else
    redirect_to admin_contact_message_path(@contact_message), alert: "Reply cannot be blank."
  end
end
  end
end