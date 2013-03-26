class UserMailer < ActionMailer::Base
  default from: "notifications@dbld8.com"

  def welcome_email(user)
    @user = user
    @subject = "Welcome to DoubleDate Beta!"    
    mail(:to => @user.email, :subject => @subject)
  end

end
