class AddCurrentJidToChannels < ActiveRecord::Migration[5.1]
  def change
    add_column :channels, :current_jid, :string
  end
end
