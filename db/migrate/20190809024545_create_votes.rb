class CreateVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :votes do |t|
      t.string :song_title
      t.string :spotify_song_id
      t.string :voter_ip

      t.timestamps
    end
  end
end
