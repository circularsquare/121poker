class CreatePlayersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :players do |t|
      t.string :ai
      t.string :username
      t.integer :game_id
      t.integer :user_id
      t.string :location
      t.integer :money

      t.timestamps

    end
  end
end
