class VotingService
  def self.vote(options={})
    self.new(options).vote
  end

  def initialize(options)
    @channel = options[:channel]
    @user = User.find(options[:vote][:user_id])
    @new_vote = options[:vote]
    return {error: "no channel found"} if @channel.blank?
    return {error: "no vote sent"} if @new_vote.blank?
  end

  def vote
    current_vote = RedisUtilities::user_vote(@channel.name, @user.id)
    return {alert: "No new vote"} if current_vote.present? && @new_vote[:id] == current_vote[:id]
    
    result = persist_vote
    PusherUtilities::broadcast_vote(@channel.name, @new_vote)
    result
  end
  
  def persist_vote
    if @new_vote.blank?
      return {alert: "No new vote"}
    end

    current_votes = RedisUtilities::add_vote(@channel.name, @new_vote)

    return {new_vote: @new_vote, current_votes: current_votes}
  end

end