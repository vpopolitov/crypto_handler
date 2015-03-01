module SessionsHelper
  def sign_in(user)
    cookies.permanent[:remember_token] = {
        value: user.remember_token,
        httponly: true
    }
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end
end
