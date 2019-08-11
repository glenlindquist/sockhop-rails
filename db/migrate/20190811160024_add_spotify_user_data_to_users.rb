class AddSpotifyUserDataToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :spotify_user_data, :json
  end
end
