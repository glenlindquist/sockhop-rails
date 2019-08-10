json.extract! vote, :id, :song_title, :spotify_song_id, :voter_ip, :created_at, :updated_at
json.url vote_url(vote, format: :json)
