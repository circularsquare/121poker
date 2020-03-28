class TurnOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :current_player, :integer
    add_column :games, :high_better, :integer
  end
end
