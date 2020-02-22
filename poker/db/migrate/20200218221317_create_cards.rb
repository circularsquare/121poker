# file made by andrew while doing tutorial, run rails db:migrate to generate a table of cards?

class CreateCards < ActiveRecord::Migration[6.0]
  def change
    create_table :cards do |t|
      t.integer :card_id
      t.string :suit
      t.string :rank
      t.string :location
      t.timestamps
    end
  end
end
