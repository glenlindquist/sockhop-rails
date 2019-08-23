class VotingService
  def self.vote(options={})
    self.new(options).vote
  end

  def initialize(options)
    @channel = options[:channel]
    @new_vote = options[:vote]
    return {error: "no channel found"} if @channel.blank?
    return {error: "no vote sent"} if @new_vote.blank?
  end

  def vote
    result = persist_vote
    # check if successfully persisted?
    PusherUtilities::broadcast_vote(@channel.name, @new_vote)
    result
  end
  
  def persist_vote
    if @new_vote.blank?
      return {alerrt: "No new vote"}
    end

    current_votes = RedisUtilities::add_vote(@channel.name, @new_vote)

    return {new_vote: @new_vote, current_votes: current_votes}
  end

end