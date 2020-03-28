class AddPot < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :pot, :integer
  end
end
