require 'rspotify'

class HostWorker
  include Sidekiq::Worker
  def perform(options)
    @spotify_user = RSpotify::User.new(options["spotify_user_hash"])
    @most_recent_track_id = ""
    @channel = Channel.find(options["channel_id"])
    loop do
      break if cancelled?
      # a bit dangerous... add some sort of time out

      if @spotify_user.player && @spotify_user.player.currently_playing
        current_track = @spotify_user.player.currently_playing
        broadcast_current_track if @most_recent_track_id != current_track.id
        @most_recent_track_id = current_track.id

        puts @spotify_user.player.currently_playing.name
      else
        puts "Player not open"
      end
      sleep 10
    end
  end

  def cancelled?
    Sidekiq.redis {|c| c.exists("cancelled-#{jid}") }
  end

  # Duplicates stuff already in host service.. how best to refactor?
  def broadcast_current_track
    channels_client = init_pusher
    channels_client.trigger(@channel.name, 'current_track', current_track)
  end

  def current_track
    #formats into more the key info for js to display.
    return {} if @spotify_user.player.blank?
    SpotifySearchService.format_track(@spotify_user.player.currently_playing)
  end

  def init_pusher
    Pusher::Client.new(
      app_id: ENV['pusher_app_id'],
      key: ENV['pusher_key'],
      secret: ENV['pusher_secret'],
      cluster: ENV['pusher_cluster'],
      use_tls: true
    )
  end
  # /duplication

  def self.cancel!(jid)
    puts 'canceling!'
    Sidekiq.redis {|c| c.setex("cancelled-#{jid}", 86400, 1) }
  end
  
end
