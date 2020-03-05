class CreateCards < ActiveRecord::Migration[6.0]
  def change
    create_table :cards do |t|
      t.string :suit
      t.string :rank
      t.string :location
      t.integer :game_id

      t.timestamps
    end
  end
end
