class AddBlinds < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :big_blind, :integer
    add_column :games, :small_blind, :integer
  end
end
