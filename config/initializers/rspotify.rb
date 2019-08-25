module RSpotify
  class Player < Base

    def initialize(user, options = {})
      # Identical to init regular method, but with currently_playing_type added
      
      @user = user

      @repeat_state           = options['repeat_state']
      @shuffle_state          = options['shuffle_state']
      @progress               = options['progress_ms']
      @is_playing             = options['is_playing']

      # addded
      @currently_playing_type = options['currently_playing_type']

      @track = if options['track']
        Track.new options['track']
      end

      @device = if options['device']
        Device.new options['device']
      end
    end

    def currently_playing
      # Again need to handle the case that this is not a 'track'

      url = "me/player/currently-playing"
      response = RSpotify.resolve_auth_request(@user.id, url)
      return response if RSpotify.raw_response

      # added
      return nil unless response && response["item"]
      
      Track.new response["item"]
    end

  end
end