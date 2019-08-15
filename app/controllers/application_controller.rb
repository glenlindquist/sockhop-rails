class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_channel

  def current_channel
    if session[:channel_name]
      @current_channel ||= Channel.find_by(name: session[:channel_name])
    else
      @current_channel = nil
    end
  end

  def check_user
    if @user != current_user
      redirect_to '/', alert: 'unauthorized action'
    end
  end

end
