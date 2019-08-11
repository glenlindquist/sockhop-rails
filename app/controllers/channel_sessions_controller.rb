class ChannelSessionsController < ApplicationController
  
  def new
  end

  def create
    channel = Channel.find_by_name(params[:name])
    if channel && channel.authenticate(params[:password])
      session[:channel_id] = channel.id
      redirect_to channels_path(channel), notice: "welcome!"
    else
      flash.now[:alert] = "name or password invalid"
      render 'new'
    end
  end

  def destroy
    session[:channel_id] = nil
    redirect_to root_url, 'come again soon!'
  end

end