class UserMailer < ApplicationMailer
  default from: "no-reply@luxecart.example"

  def login_notification(user)
    @user = user
    mail(
      to: @user.email,
      subject: "You successfully logged in to LuxeCart"
    )
  end
end