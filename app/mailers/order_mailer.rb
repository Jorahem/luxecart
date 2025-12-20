class OrderMailer < ApplicationMailer
  default from: ENV.fetch('DEFAULT_EMAIL_FROM', 'noreply@luxecart.com')

  # Send order confirmation email
  def order_confirmation(order)
    @order = order
    @user = order.user
    @order_items = order.order_items.includes(:product)
    
    mail(
      to: @user.email,
      subject: "Order Confirmation - Order ##{@order.order_number}"
    )
  end

  # Send shipping notification email
  def shipping_notification(order)
    @order = order
    @user = order.user
    @tracking_number = order.tracking_number
    
    mail(
      to: @user.email,
      subject: "Your Order ##{@order.order_number} Has Been Shipped"
    )
  end

  # Send order cancellation email
  def order_cancellation(order)
    @order = order
    @user = order.user
    
    mail(
      to: @user.email,
      subject: "Order Cancelled - Order ##{@order.order_number}"
    )
  end

  # Send delivery confirmation email
  def delivery_confirmation(order)
    @order = order
    @user = order.user
    
    mail(
      to: @user.email,
      subject: "Your Order ##{@order.order_number} Has Been Delivered"
    )
  end
end
