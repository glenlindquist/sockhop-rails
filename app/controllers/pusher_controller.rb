class PusherController < ApplicationController

  def auth
    if current_user
      pusher_client = init_pusher
      response = pusher_client.authenticate(params[:channel_name], params[:socket_id], {
        user_id: current_user.id, # => required
        user_info: {
          id: current_user.id,
          is_host: sockhop_channel(params[:channel_name]).user == current_user
        }
      })
      render json: response
    else
      render text: 'Forbidden', status: '403'
    end
  end

  def sockhop_channel(pusher_presence_channel)
    Channel.find_by(name: pusher_presence_channel.gsub(/\Apresence-/, ""))
  end

end