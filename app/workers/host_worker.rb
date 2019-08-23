require 'rspotify'

class HostWorker
  include Sidekiq::Worker
  def perform(options)
    @spotify_user = RSpotify::User.new(options["spotify_user_hash"])
    @current_track = SpotifyUtilities::current_track(spotify_user: @spotify_user)
    @channel = Channel.find(options["channel_id"])
    @playlist = RSpotify::Playlist.find_by_id(options["playlist_id"])
    @cooldown = options.fetch("cooldown", 15000) # 15 seconds

    loop do
      break if cancelled?
      # a bit dangerous... add some sort of time out
      player = @spotify_user.player

      if player
        new_track = SpotifyUtilities::current_track(player: player)
        if new_track[:id] != @current_track[:id]
          @current_track = new_track
          register_track_change
        end
        remaining_ms = new_track[:duration_ms] - player.progress

        if remaining_ms <= @cooldown
          handle_winner
        end

        puts @current_track[:name]
        puts "Time Remaining: #{SpotifyUtilities::readable_duration(remaining_ms)}"
      else
        puts "Player not open"
      end

      sleep 10
    end
  end

  def cancelled?
    Sidekiq.redis {|c| c.exists("cancelled-#{jid}") }
  end
  
  def register_track_change
    PusherUtilities::broadcast_current_track(@channel.name, @current_track)
    RedisUtilities::change_current_track(@channel.name, @current_track)
    restart_voting
  end

  def handle_winner
    close_voting
    winner = RedisUtilities::winning_track(@channel.name)
    puts "WINNER: #{winner['name']}"
    @playlist.add_tracks! [RSpotify::Track.find(winner['id'])]
    # broadcast_up_next
    # broadcast_clear_votes
  end

  def restart_voting
    RedisUtilities::clear_votes!(@channel.name)
    open_voting
  end

  def open_voting

  end

  def close_voting

  end
  

  def self.cancel!(jid)
    puts 'canceling!'
    Sidekiq.redis {|c| c.setex("cancelled-#{jid}", 86400, 1) }
  end

  def self.cancelled?(jid)
    Sidekiq.redis {|c| c.exists("cancelled-#{jid}") }
  end
  
end
