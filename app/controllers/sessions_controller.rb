class SessionsController < ApplicationController

  def new
  end

  def create
    email = params[:session][:email].downcase
    user = User.find_by(email: email)
    if user && user_signed_in?
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
      else
        message = "Account not activated, check your email for the activation link."
        message += "<br/>If you didn't receive the email, "
        message += view_context.link_to('click here', resend_path(email: email))
        message += " to resend the verification email."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def resend
    user = User.find_by(email: params[:email]) 
    if user && !user.activated?
      user.send_activation_email
      flash[:info] = "Email resent. Please check your email to activate your account."
    else
      flash[:danger] = 'This email address is not associated with any account.'
    end
    redirect_to root_url
  end

end