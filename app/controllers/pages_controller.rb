class PagesController < ApplicationController
  # GET / (if you choose to use pages#home as root)
  def home
    @featured_products = Product.limit(6) if defined?(Product)
  end

  def about
  end

  def contact
  end


    def privacy
  end

  def terms
  end



  def contact_submit
    contact = contact_params
    Rails.logger.info("[ContactForm] Received message: #{contact.inspect}")
    flash[:notice] = "Thank you — your message has been received. We'll get back to you soon."
    redirect_to contact_path
  end

  def returns
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message)
  end
end