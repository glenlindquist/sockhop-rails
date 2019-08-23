module RedisUtilities
  extend self

  def clear_votes!(channel_name)
    redis.set("#{channel_name}_votes", [].to_json)
  end

  def current_votes(channel_name)
    votes = redis.get("#{channel_name}_votes")
    if votes.blank?
      return []
    else
      JSON.parse(votes).sort_by {|track| track['vote_count']}.reverse
    end
  end

  def current_track(channel_name)
    track = redis.get("#{channel_name}_current_track")
    track = JSON.parse(track) if track
    track ||= {}
  end

  def add_vote(channel_name, new_vote)
    # check if this is a brand new track or if it already has votes
    current_votes = current_votes(channel_name)
    matching_vote = current_votes.select{|track| track['id'] == new_vote['id']}[0]

    if matching_vote.present?
      current_votes = current_votes - [matching_vote]
      new_vote = matching_vote
    end
    
    new_vote["vote_count"] += 1

    current_votes << new_vote

    redis.set("#{channel_name}_votes", current_votes.to_json)
    
    current_votes
  end

  def change_current_track(channel_name, track)
    redis.set("#{channel_name}_current_track", track.to_json)
  end

  def change_host_presence(channel_name, host_presence)
    redis.set("#{channel_name}_host_presence", host_presence)
  end

  def winning_track(channel_name)
    tracks = current_votes(channel_name)
    return if tracks.blank?
    tracks.max_by{|track| track['vote_count'].to_i}
  end

  def redis
    Redis.new
  end
end