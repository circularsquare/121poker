class InRoundBet < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :high_bet, :integer
    add_column :players, :in_hand, :boolean
  end
end
