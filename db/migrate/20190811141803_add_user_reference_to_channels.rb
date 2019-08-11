class AddUserReferenceToChannels < ActiveRecord::Migration[5.1]
  def change
    add_reference :channels, :user, foreign_key: true
  end
end
