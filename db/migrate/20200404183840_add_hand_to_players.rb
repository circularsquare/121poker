class AddHandToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :hand, :string
  end
end
