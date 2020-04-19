# Sockhop [WIP]

A Spotify-based service where a user can create a channel for other users to vote on the next song—a democratic jukebox.

Votes are persisted to Redis.

Pusher notifies channel viewers of song changes and incoming votes.

React for front-end.

A lot of changes need to be made.
* Auth/signups need to be simplified.
* Extract a lot of the logic from Sidekiq and move client-side.