class Dealer < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :dealer, :integer
  end
end
