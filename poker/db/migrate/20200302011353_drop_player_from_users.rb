class DropPlayerFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :player
  end
end
