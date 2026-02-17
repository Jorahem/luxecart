class ContactMessagesController < ApplicationController
  before_action :authenticate_user!

  def new
    @contact_message = ContactMessage.new(name: current_user.name)
  end

  def create
    @contact_message = ContactMessage.new(contact_message_params)
    @contact_message.email = current_user.email # ✅ force from login

    if @contact_message.save
      redirect_to new_contact_message_path, notice: "Message sent successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:name, :subject, :message)
  end

  def reply
  @contact_message = ContactMessage.find(params[:id])

  reply_text = params[:contact_message][:reply]

  if reply_text.present?
    @contact_message.update!(
      reply: reply_text,
      reply_at: Time.zone.now
    )
    redirect_to admin_contact_message_path(@contact_message), notice: "Reply sent to customer."
  else
    flash.now[:alert] = "Reply cannot be blank."
    render :show, status: :unprocessable_entity
  end
end
end