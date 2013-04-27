class UserMailer < ActionMailer::Base
  default from: "DoubleDate <notifications@dbld8.com>"

  def welcome_email(user)
    @user = user
    @subject = t('welcome_email.subject')
    mail(:to => @user.email, :subject => @subject) if @user.email.present?
  end

end
