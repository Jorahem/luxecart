class PagesController < ApplicationController
  # Require login for contact page + submit (so we can use current_user.email)
  before_action :authenticate_user!, only: [:contact, :contact_submit]

  # GET /
  def home
    @featured_products = Product.limit(6) if defined?(Product)
  end

  def about
  end

  def privacy
  end

  def terms
  end

  # GET /contact
  def contact
    # Prefill name if present and load previous messages for display
    @contact = {
      name: (current_user.respond_to?(:name) ? current_user.name : nil),
      subject: nil,
      message: nil
    }
    @contact_messages = ContactMessage.where(email: current_user.email).order(created_at: :desc)
  end

  # POST /contact_submit
  def contact_submit
    # Your form currently sends params under :contact (based on your contact_params method)
    data = contact_params

    @contact_message = ContactMessage.new(
      name: data[:name],
      email: current_user.email,   # ✅ force email from logged-in user
      subject: data[:subject],
      message: data[:message]
    )

    if @contact_message.save
      redirect_to contact_path, notice: "Thank you — your message has been received. We'll get back to you soon."
    else
      flash.now[:alert] = @contact_message.errors.full_messages.to_sentence
      @contact = data
      # Also reload past messages for re-render
      @contact_messages = ContactMessage.where(email: current_user.email).order(created_at: :desc)
      render :contact, status: :unprocessable_entity
    end
  end

  def returns
  end

  private

  # NOTE: :email is not permitted because we'll use current_user's email
  def contact_params
    params.require(:contact).permit(:name, :subject, :message)
  end
end