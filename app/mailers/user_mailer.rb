class UserMailer < ApplicationMailer
  default from: ENV.fetch('DEFAULT_EMAIL_FROM', 'noreply@luxecart.com')

  # Welcome email for new users
  def welcome_email(user)
    @user = user
    
    mail(
      to: @user.email,
      subject: "Welcome to #{ENV.fetch('APP_NAME', 'LuxeCart')}!"
    )
  end

  # Product back in stock notification
  def back_in_stock_notification(user, product)
    @user = user
    @product = product
    
    mail(
      to: @user.email,
      subject: "#{@product.name} is Back in Stock!"
    )
  end
end
