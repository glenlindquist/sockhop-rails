module PusherUtilities
  extend self

  def broadcast_vote(channel_name, new_vote)
    pusher_client.trigger(channel_name, 'new_vote', new_vote)
  end

  def broadcast_current_track(channel_name, current_track)
    pusher_client.trigger(channel_name, 'current_track', current_track)
  end

  def broadcast_host_presence(channel_name, presence)
    pusher_client.trigger(channel_name, 'host_presence', presence)
  end

  def broadcast_vote_status(channel_name, status)
    pusher_client.trigger(channel_name, 'vote_status', status)
  end

  def broadcast_next_track(channel_name, next_track)
    pusher_client.trigger(channel_name, 'next_track', next_track)
  end

  def pusher_client
    Pusher::Client.new(
      app_id: ENV['pusher_app_id'],
      key: ENV['pusher_key'],
      secret: ENV['pusher_secret'],
      cluster: ENV['pusher_cluster'],
      use_tls: true
    )
  end
end