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
end