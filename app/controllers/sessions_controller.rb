class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by email: params[:session][:email]
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_to categories_url
    else
      flash.now[:error] = "Неправильная пара адрес/пароль"
      render 'new'
    end
  end
end
