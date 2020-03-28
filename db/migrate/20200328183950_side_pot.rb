class SidePot < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :in_pot_current, :integer
    add_column :players, :in_pot_hand, :integer
  end
end
