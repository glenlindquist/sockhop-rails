class ChannelSessionsController < ApplicationController
  before_action :require_login, except: [:new, :create]

  def new
    @channel = Channel.new
  end

  def create
    @channel = login(params[:name], params[:password])

    if @channel
      redirect_to @channel, notice: "welcome to the party"
    else
      flash.now[:alert] = "login failed"
      render action: 'new'
    end
  end

  def destroy
    logout
    redirect_to '/', notice: 'bye!'
  end
end