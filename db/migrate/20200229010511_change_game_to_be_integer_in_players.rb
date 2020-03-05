class ChangeGameToBeIntegerInPlayers < ActiveRecord::Migration[6.0]
  def change
    change_column :players, :game, :integer
    rename_column :players, :game, :game_id
  end
end
