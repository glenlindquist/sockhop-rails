class VotingService
  def self.send_vote(options={})
    service = self.new(options)
    result = service.persist_vote
    # Check if vote succesfully persisted?
    service.broadcast_vote

    result
  end

  # todo: rethink architecture.
  def self.clear_votes(options={})
    redis = Redis.new
    channel = options[:channel]
    redis_key = "#{channel.id}_votes"
    redis.set(redis_key, [].to_json)
  end

  def initialize(options)
    @redis = Redis.new
    @channel = options[:channel]
    @new_vote = options[:vote]
    @redis_key = "#{@channel.id}_votes"
    return {error: "no channel found"} if @channel.blank?
    return {error: "no vote sent"} if @new_vote.blank?
  end
  
  def persist_vote
    current_votes = get_current_votes

    if @new_vote.blank?
      return {new_vote: "No new vote", currrent_votes: current_votes}
    end

    # check if this is a brand new track or if it already has votes
    matching_vote = current_votes.select{|track| track['id'] == @new_vote['id']}[0]

    if matching_vote.present?
      current_votes = current_votes - [matching_vote]
      @new_vote = matching_vote
    end
    
    @new_vote["vote_count"] += 1

    current_votes << @new_vote
    @redis.set(@redis_key, current_votes.to_json)

    return {new_vote: @new_vote, current_votes: current_votes}
  end

  def broadcast_vote
    channels_client = init_pusher
    channels_client.trigger("#{@channel.id}", 'new_vote', @new_vote)
  end

  def get_current_votes
    current_votes = @redis.get(@redis_key)
    if current_votes.blank?
      []
    else
      JSON.parse(current_votes).sort_by {|track| -track['vote_count']}
    end
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

end