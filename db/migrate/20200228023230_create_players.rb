class CreatePlayers < ActiveRecord::Migration[6.0]
  def change
    create_table :players do |t|
      t.string :ai
      t.string :username
      t.string :game
      t.string :location

      t.timestamps
    end
  end
end
