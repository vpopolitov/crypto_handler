class SessionsController < ApplicationController
  def new

  end

  def create
    redirect_to categories_url
  end
end
