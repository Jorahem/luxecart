class ChatController < ApplicationController
  protect_from_forgery with: :null_session
  # If you want only logged-in users, uncomment the next line:
  # before_action :authenticate_user!

  def create
    message = params[:message].to_s.strip

    if message.blank?
      render json: { error: "Message is empty" }, status: :unprocessable_entity
      return
    end

    # === PLACEHOLDER AI LOGIC ===
    #
    # Replace this block with a real AI call (OpenAI, etc.)
    # For now, we’ll just generate a simple rule-based response so it
    # feels more dynamic than the same hard-coded text.

    response_text =
      case message.downcase
      when /hello|hi|hey/
        "Hi there! 👋 How can I help you with LuxeCart today?"
      when /order|track|tracking/
        "You can track your orders from your profile's Orders section. If you share your order ID, I can give more specific help."
      when /refund|return/
        "Our return window is 14 days from delivery for most items, as long as they’re unused with tags. I can walk you through the steps if you tell me your order ID."
      when /size|sizing/
        "Sizing can vary by brand. Check the size chart on each product page. If you tell me the product name and your usual size, I can suggest a fit."
      when /payment|card|stripe/
        "We process payments securely using Stripe. We accept major credit/debit cards and some digital wallets depending on your region."
      else
        "I’m still a simple assistant. In production you can connect me to a full AI model and product/order data, but here’s what I understood: “#{message}”. Tell me more and I’ll try to guide you."
      end

    render json: { reply: response_text }
  end
end