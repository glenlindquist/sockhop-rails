module RSpotify
  class Player < Base

    def initialize(user, options = {})
      # Identical to init regular method, but with currently_playing_type added
      
      @user = user

      @repeat_state           = options['repeat_state']
      @shuffle_state          = options['shuffle_state']
      @progress               = options['progress_ms']
      @is_playing             = options['is_playing']
      @currently_playing_type = options['currently_playing_type']

      @track = if options['track']
        Track.new options['track']
      end

      @device = if options['device']
        Device.new options['device']
      end
    end
  end
end