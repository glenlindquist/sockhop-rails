class SorceryCore < ActiveRecord::Migration[5.1]
  def change
    drop_table :channels
    drop_table :votes
    create_table :channels do |t|
      t.string :name,            null: false
      t.string :crypted_password
      t.string :salt

      t.timestamps                null: false
    end

    add_index :channels, :name, unique: true
  end
end
