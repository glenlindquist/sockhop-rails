class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_channel

  def current_channel
    if session[:channel_id]
      @current_channel ||= Channel.find(session[:channel_id])
    else
      @current_channel = nil
    end
  end

  def has_channel_privileges?
    @channel = Channel.find(params[:id])
    redirect_to(root_path, notice: "must sign into channel first") unless current_channel == @channel
  end

  def require_logout
    redirect_back(notice: 'log out before proceeding', fallback_location: '/') if logged_in?
  end

end
