class OrderMailer < ApplicationMailer
  default from: "no-reply@luxecart.example"

  def order_confirmation(order)
    @order = order
    @user  = order.user

    mail(
      to: @user&.email,
      subject: "Your LuxeCart order ##{@order.order_number.presence || @order.id} confirmation"
    )
  end
end